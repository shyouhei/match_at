/* -*- mode: c; coding: utf-8; indent-tabs-mode: nil -*- */
/* Copyright (c) 2017 Urabe, Shyouhei
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this  software and  associated documentation  files (the  "Software"), to
 * deal in the  Software without restriction, including  without limitation the
 * rights to use, copy, modify,  merge, publish, distribute, sublicense, and/or
 * sell copies of the  Software, and to permit persons to  whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 *      The above copyright notice and this permission notice shall be
 *      included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS  PROVIDED "AS IS", WITHOUT WARRANTY OF  ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING  BUT NOT  LIMITED TO  THE WARRANTIES  OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND  NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS  OR COPYRIGHT  HOLDERS BE  LIABLE FOR  ANY CLAIM,  DAMAGES OR  OTHER
 * LIABILITY,  WHETHER IN  AN ACTION  OF CONTRACT,  TORT OR  OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#include <stdbool.h>
#include <ruby/ruby.h>
#include <ruby/re.h>
#include <ruby/encoding.h>

static VALUE match_at(VALUE RB_UNUSED_VAR(mod), VALUE str, VALUE rexp, VALUE pos);
static VALUE match_at_p(VALUE RB_UNUSED_VAR(mod), VALUE str, VALUE rexp, VALUE pos);
static OnigPosition do_match(VALUE str, VALUE rexp, VALUE pos, OnigRegion *region);

/**
 * Match the rexp  against str's position pos.  This is  lightweight because no
 * MatchData is allocated.
 *
 * @param str  [String]  target string.
 * @param rexp [Regexp]  pattern to match.
 * @param pos  [Integer] str's index, in character.
 * @return     [true]    successful match.
 * @return     [false]   failure in match.
 */
VALUE
match_at_p(VALUE mod, VALUE str, VALUE rexp, VALUE pos)
{
    OnigPosition result = do_match(str, rexp, pos, NULL);

    if (result >= 0) {
        long n           = NUM2LONG(pos);
        rb_encoding *enc = rb_enc_get(str);
        const char *beg  = rb_string_value_ptr(&str);
        const char *end  = RSTRING_END(str);
        const char *ptr  = rb_enc_nth(beg, end, n, enc);
        const char *term = &ptr[result];
        long len         = rb_enc_strlen(ptr, term, enc);

        return LONG2NUM(len);
    }
    else {
        return Qnil;
    }
}

/**
 * Try to  construct a  MatchData at  str's pos  position.  If  that's possible
 * return the allocated MatchData.  Otherwise, returns nil.
 *
 * @note  It does not update `$~`.
 * @param str  [String]    target string.
 * @param rexp [Regexp]    pattern to match.
 * @param pos  [Integer]   str's index, in character.
 * @return     [MatchData] successful match.
 * @return     [nil]       failure in match.
 */
VALUE
match_at(VALUE mod, VALUE str, VALUE rexp, VALUE pos)
{
    OnigRegion region   = { 0 };
    VALUE ret           = Qnil;
    OnigPosition result = do_match(str, rexp, pos, &region);

    if (result >= 0) {
        int err;
        ret = rb_funcall(rb_cMatch, rb_intern("allocate"), 0);
        err = rb_reg_region_copy(RMATCH_REGS(ret), &region);
        if (err) {
            rb_memerror();
        }
        else {
            RMATCH(ret)->regexp = rexp;
            RMATCH(ret)->str    = rb_str_new_frozen(str); /* copy */
            OBJ_INFECT(ret, rexp);
            OBJ_INFECT(ret, str);
            /* no backref introduced, OK write barrier. */
        }
    }
    onig_region_free(&region, 0);
    return ret;
}

OnigPosition
do_match(VALUE vstr, VALUE vreg, VALUE vpos, OnigRegion *region)
{
    const char *str;
    const char *end;
    const char *ptr;
    const rb_encoding *enc;
    long pos;
    OnigRegex reg;
    OnigPosition result;
    bool tmpreg;

    Check_Type(vreg, T_REGEXP);

    pos    = NUM2LONG(vpos);
    str    = rb_string_value_ptr(&vstr);
    enc    = rb_enc_check(vstr, vreg);
    end    = RSTRING_END(vstr);
    ptr    = rb_enc_nth(str, end, pos, enc);
    reg    = rb_reg_prepare_re(vreg, vstr);
    tmpreg = (reg != RREGEXP_PTR(vreg));

    /* This !tmpreg maneuver is required to prevent memory leaks. */
    if (!tmpreg) RREGEXP(vreg)->usecnt++;
    result = onig_match(reg, (OnigUChar *)str, (OnigUChar *)end,
                        (OnigUChar *)ptr, region, ONIG_OPTION_NONE);
    if (!tmpreg) RREGEXP(vreg)->usecnt--;

    if (tmpreg) {
	if (RREGEXP(vreg)->usecnt) {
	    onig_free(reg);
	}
	else {
	    onig_free(RREGEXP_PTR(vreg));
	    RREGEXP_PTR(vreg) = reg;
	}
    }

    if ((result >= 0) || (result == ONIG_MISMATCH)) {
        return result;
    }
    else {
        OnigUChar err[ONIG_MAX_ERROR_MESSAGE_LEN] = { 0 };
        onig_error_code_to_str(err, (int)result);
        rb_raise(rb_eRegexpError, "%s: %+"PRIsVALUE, err, vreg);
    }
}

void
Init_match_at(void)
{
    VALUE mod = rb_define_module("MatchAt");
    rb_define_module_function(mod, "match_at?", match_at_p, 3);
    rb_define_module_function(mod, "match_at",  match_at,   3);
}
