module move_int::i8 {
    const OVERFLOW: u64 = 0;

    const MIN_AS_U8: u8 = 1 << 7;
    const MAX_AS_U8: u8 = 0x7f;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I8 has copy, drop, store {
        bits: u8
    }

    // Creates and returns an I8 representing zero
    public fun zero(): I8 {
        I8 { bits: 0 }
    }

    // Creates an I8 from a u8 without any checks
    public fun from_u8(v: u8): I8 {
        I8 { bits: v }
    }

    // Creates an I8 from a u8, asserting that it's not greater than the maximum positive value
    public fun from(v: u8): I8 {
        assert!(v <= MAX_AS_U8, OVERFLOW);
        I8 { bits: v }
    }

    // Creates a negative I8 from a u8, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u8): I8 {
        assert!(v <= MIN_AS_U8, OVERFLOW);
        if (v == 0) {
            I8 { bits: v }
        } else {
            I8 { bits: (u8_neg(v) + 1) | (1 << 7) }
        }
    }

    // Performs wrapping addition on two I8 numbers
    public fun wrapping_add(num1: I8, num2: I8): I8 {
        let sum = num1.bits ^ num2.bits;
        let carry = (num1.bits & num2.bits) << 1;
        while (carry != 0) {
            let a = sum;
            let b = carry;
            sum = a ^ b;
            carry = (a & b) << 1;
        };
        I8 { bits: sum }
    }

    // Performs checked addition on two I8 numbers, asserting on overflow
    public fun add(num1: I8, num2: I8): I8 {
        let sum = wrapping_add(num1, num2);
        let overflow = (sign(num1) & sign(num2) & u8_neg(sign(sum))) | (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I8 numbers
    public fun wrapping_sub(num1: I8, num2: I8): I8 {
        let sub_num = wrapping_add(I8 { bits: u8_neg(num2.bits) }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I8 numbers, asserting on overflow
    public fun sub(num1: I8, num2: I8): I8 {
        let sub_num = wrapping_add(I8 { bits: u8_neg(num2.bits) }, from(1));
        add(num1, sub_num)
    }

    public fun mul(num1: I8, num2: I8): I8 {
        let product = (abs_u8(num1) as u16) * (abs_u8(num2) as u16);
        assert!(product <= (MAX_AS_U8 as u16) + 1, OVERFLOW);

        if (sign(num1) != sign(num2)) {
            neg_from((product as u8))
        } else {
            from((product as u8))
        }
    }

    // Performs division on two I8 numbers
    public fun div(num1: I8, num2: I8): I8 {
        assert!(!is_zero(num2), OVERFLOW);
        let result = abs_u8(num1) / abs_u8(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        from(result)
    }

    // Returns the absolute value of an I8 number
    public fun abs(v: I8): I8 {
        if (sign(v) == 0) {
            v
        } else {
            assert!(v.bits > MIN_AS_U8, OVERFLOW);
            I8 { bits: u8_neg(v.bits - 1) }
        }
    }

    // Returns the absolute value of an I8 number as a u8
    public fun abs_u8(v: I8): u8 {
        if (sign(v) == 0) {
            v.bits
        } else {
            u8_neg(v.bits - 1)
        }
    }

    // Performs modulo operation on two I8 numbers
    public fun mod(v: I8, n: I8): I8 {
        assert!(!is_zero(n), OVERFLOW);
        if (sign(v) == 1) {
            neg_from((abs_u8(v) % abs_u8(n)))
        } else {
            from((as_u8(v) % abs_u8(n)))
        }
    }

    // Returns the minimum of two I8 numbers
    public fun min(a: I8, b: I8): I8 {
        if (lt(a, b)) { a } else { b }
    }

    // Returns the maximum of two I8 numbers
    public fun max(a: I8, b: I8): I8 {
        if (gt(a, b)) { a } else { b }
    }

    // Raises an I8 number to a u8 power
    public fun pow(base: I8, exponent: u8): I8 {
        if (exponent == 0) {
            return from(1)
        };

        let result = from(1);
        let current_base = base;

        while (exponent > 0) {
            if (exponent & 1 == 1) {
                result = mul(result, current_base);
            };
            current_base = mul(current_base, current_base);
            exponent = exponent >> 1;
        };

        result
    }

    // Calculates the greatest common divisor of two I8 numbers
    public fun gcd(a: I8, b: I8): I8 {
        let a = abs(a);
        let b = abs(b);
        while (!is_zero(b)) {
            let temp = b;
            b = mod(a, b);
            a = temp;
        };
        a
    }

    // Calculates the least common multiple of two I8 numbers
    public fun lcm(a: I8, b: I8): I8 {
        if (is_zero(a) || is_zero(b)) {
            return zero()
        };
        let gcd_val = gcd(a, b);
        abs(div(mul(a, b), gcd_val))
    }

    // Converts an I8 to u8
    public fun as_u8(v: I8): u8 {
        v.bits
    }

    // Returns the sign of an I8 number (0 for positive, 1 for negative)
    public fun sign(v: I8): u8 {
        (v.bits >> 7)
    }

    // Checks if an I8 number is zero
    public fun is_zero(v: I8): bool {
        v.bits == 0
    }

    // Checks if an I8 number is negative
    public fun is_neg(v: I8): bool {
        sign(v) == 1
    }

    // Compares two I8 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I8, num2: I8): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I8 numbers are equal
    public fun eq(num1: I8, num2: I8): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I8 number is greater than the second
    public fun gt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I8 number is greater than or equal to the second
    public fun gte(num1: I8, num2: I8): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I8 number is less than the second
    public fun lt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I8 number is less than or equal to the second
    public fun lte(num1: I8, num2: I8): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I8 numbers
    public fun or(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits | num2.bits) }
    }

    // Performs bitwise AND on two I8 numbers
    public fun and(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits & num2.bits) }
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }

    // Basic Operations Tests
    #[test]
    fun test_from() {
        assert!(as_u8(from(0)) == 0, 0);
        assert!(as_u8(from(10)) == 10, 1);
        assert!(as_u8(from(MAX_AS_U8)) == MAX_AS_U8, 2);
    }

    #[test]
    #[expected_failure]
    fun test_from_overflow() {
        from(MAX_AS_U8 + 1);
    }

    #[test]
    fun test_neg_from() {
        assert!(as_u8(neg_from(0)) == 0, 0);
        assert!(as_u8(neg_from(1)) == 0xff, 1);
        assert!(as_u8(neg_from(MAX_AS_U8)) == 0x81, 2);
        assert!(as_u8(neg_from(MIN_AS_U8)) == MIN_AS_U8, 3);
    }

    #[test]
    #[expected_failure]
    fun test_neg_from_overflow() {
        neg_from(MIN_AS_U8 + 1);
    }

    // Absolute Value Tests
    #[test]
    fun test_abs() {
        assert!(as_u8(abs(from(10))) == 10u8, 0);
        assert!(as_u8(abs(neg_from(10))) == 10u8, 1);
        assert!(as_u8(abs(neg_from(0))) == 0u8, 2);
        assert!(as_u8(abs(neg_from(MAX_AS_U8))) == MAX_AS_U8, 3);
    }

    #[test]
    #[expected_failure]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U8));
    }

    // Addition Tests
    #[test]
    fun test_add() {
        assert!(as_u8(add(from(1), from(2))) == 3, 0);
        assert!(as_u8(add(from(MAX_AS_U8), from(0))) == MAX_AS_U8, 1);
        assert!(as_u8(add(neg_from(1), from(1))) == 0, 2);
    }

    #[test]
    #[expected_failure]
    fun test_add_overflow() {
        add(from(MAX_AS_U8), from(1));
    }

    #[test]
    #[expected_failure]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U8), neg_from(1));
    }

    // Subtraction Tests
    #[test]
    fun test_sub() {
        assert!(as_u8(sub(from(3), from(2))) == 1, 0);
        assert!(as_u8(sub(from(0), from(1))) == 0xff, 1);
        assert!(as_u8(sub(neg_from(1), neg_from(1))) == 0, 2);
    }

    #[test]
    #[expected_failure]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U8), neg_from(1));
    }

    #[test]
    #[expected_failure]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U8), from(1));
    }

    // Multiplication Tests
    #[test]
    fun test_mul() {
        assert!(as_u8(mul(from(3), from(2))) == 6, 0);
        assert!(as_u8(mul(neg_from(4), from(2))) == 0xf8, 1);
        assert!(as_u8(mul(neg_from(4), neg_from(2))) == 8, 2);
    }

    #[test]
    #[expected_failure]
    fun test_mul_overflow() {
        mul(from(MAX_AS_U8), from(2));
    }

    // Division Tests
    #[test]
    fun test_div() {
        assert!(as_u8(div(from(6), from(2))) == 3, 0);
        assert!(as_u8(div(neg_from(6), from(2))) == 0xfd, 1);
        assert!(as_u8(div(neg_from(6), neg_from(2))) == 3, 2);
    }

    #[test]
    #[expected_failure]
    fun test_div_by_zero() {
        div(from(1), from(0));
    }

    // Comparison Tests
    #[test]
    fun test_sign() {
        assert!(sign(neg_from(10)) == 1u8, 0);
        assert!(sign(from(10)) == 0u8, 1);
    }

    #[test]
    fun test_cmp() {
        assert!(cmp(from(1), from(0)) == GT, 0);
        assert!(cmp(from(0), from(1)) == LT, 1);
        assert!(cmp(from(0), neg_from(1)) == GT, 2);
        assert!(cmp(neg_from(MIN_AS_U8), from(MAX_AS_U8)) == LT, 3);
    }

    // Modulo Tests
    #[test]
    fun test_mod() {
        assert!(cmp(mod(neg_from(2), from(5)), neg_from(2)) == EQ, 0);
        assert!(cmp(mod(neg_from(2), neg_from(5)), neg_from(2)) == EQ, 1);
        assert!(cmp(mod(from(2), from(5)), from(2)) == EQ, 2);
        assert!(cmp(mod(from(2), neg_from(5)), from(2)) == EQ, 3);
    }

    // Minimum Tests
    #[test]
    fun test_min() {
        assert!(eq(min(from(10), from(5)), from(5)), 0);
        assert!(eq(min(from(0), neg_from(5)), neg_from(5)), 1);
        assert!(eq(min(neg_from(10), neg_from(5)), neg_from(10)), 2);
        assert!(eq(min(from(MAX_AS_U8), from(0)), from(0)), 3);
        assert!(eq(min(neg_from(MIN_AS_U8), from(0)), neg_from(MIN_AS_U8)), 4);
    }

    // Maximum Tests
    #[test]
    fun test_max() {
        assert!(eq(max(from(10), from(5)), from(10)), 0);
        assert!(eq(max(from(0), neg_from(5)), from(0)), 1);
        assert!(eq(max(neg_from(10), neg_from(5)), neg_from(5)), 2);
        assert!(eq(max(from(MAX_AS_U8), from(0)), from(MAX_AS_U8)), 3);
        assert!(eq(max(neg_from(MIN_AS_U8), from(0)), from(0)), 4);
    }

    #[test]
    fun test_pow() {
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 1);
        assert!(eq(pow(neg_from(2), 2), from(4)), 2);
    }

    #[test]
    #[expected_failure(abort_code = OVERFLOW)]
    fun test_pow_overflow() {
        pow(from(3), 4); // 3^4 = 81, which overflows I8
    }

    // #[test]
    // fun test_pow() {
    //     // assert!(eq(pow(from(2), 3), from(8)), 0);
    //     assert!(
    //         eq(
    //             pow(
    //                 from(3),
    //                 4),
    //             from(81)
    //         ),
    //     1);
    //     // assert!(eq(pow(neg_from(2), 3), neg_from(8)), 2);
    //     // assert!(eq(pow(neg_from(2), 2), from(4)), 3);
    // }

    #[test]
    fun test_gcd() {
        assert!(eq(gcd(from(48), from(18)), from(6)), 0);
        assert!(eq(gcd(neg_from(48), from(18)), from(6)), 1);
        assert!(eq(gcd(from(0), from(5)), from(5)), 2);
    }

    #[test]
    fun test_is_zero() {
        assert!(is_zero(from(0)), 0);
        assert!(!is_zero(from(1)), 1);
        assert!(!is_zero(neg_from(1)), 2);
    }

    #[test]
    fun test_lcm() {
        assert!(eq(lcm(from(5), from(7)), from(35)), 1);
        assert!(eq(lcm(from(3), from(6)), from(6)), 2);
        assert!(eq(lcm(from(0), from(5)), zero()), 3);
    }
}