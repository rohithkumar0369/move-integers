module move_int::i32 {

    const OVERFLOW: u64 = 0;

    const MIN_AS_U32: u32 = 1 << 31;
    const MAX_AS_U32: u32 = 0x7fffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I32 has copy, drop, store {
        bits: u32
    }

    // Creates and returns an I32 representing zero
    public fun zero(): I32 {
        I32 {
            bits: 0
        }
    }

    // Creates an I32 from a u32 without any checks
    public fun from_u32(v: u32): I32 {
        I32 {
            bits: v
        }
    }

    // Creates an I32 from a u32, asserting that it's not greater than the maximum positive value
    public fun from(v: u32): I32 {
        assert!(v <= MAX_AS_U32, OVERFLOW);
        I32 {
            bits: v
        }
    }

    // Creates a negative I32 from a u32, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u32): I32 {
        assert!(v <= MIN_AS_U32, OVERFLOW);
        if (v == 0) {
            I32 {
                bits: v
            }
        } else {
            I32 {
                bits: (u32_neg(v) + 1) | (1 << 31)
            }
        }
    }

    // Performs wrapping addition on two I32 numbers
    public fun wrapping_add(num1: I32, num2: I32): I32 {
        let sum = num1.bits ^ num2.bits;
        let carry = (num1.bits & num2.bits) << 1;
        while (carry != 0) {
            let a = sum;
            let b = carry;
            sum = a ^ b;
            carry = (a & b) << 1;
        };
        I32 {
            bits: sum
        }
    }

    // Performs checked addition on two I32 numbers, asserting on overflow
    public fun add(num1: I32, num2: I32): I32 {
        let sum = wrapping_add(num1, num2);
        let overflow = (sign(num1) & sign(num2) & u8_neg(sign(sum))) + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(
            sum
        ));
        assert!(overflow == 0, OVERFLOW);
        sum
    }

    // Performs wrapping subtraction on two I32 numbers
    public fun wrapping_sub(num1: I32, num2: I32): I32 {
        let sub_num = wrapping_add(I32 {
            bits: u32_neg(num2.bits)
        }, from(1));
        wrapping_add(num1, sub_num)
    }

    // Performs checked subtraction on two I32 numbers, asserting on overflow
    public fun sub(num1: I32, num2: I32): I32 {
        let sub_num = wrapping_add(I32 {
            bits: u32_neg(num2.bits)
        }, from(1));
        add(num1, sub_num)
    }

    // Performs multiplication on two I32 numbers
    public fun mul(num1: I32, num2: I32): I32 {
        let product = (abs_u32(num1) as u64) * (abs_u32(num2) as u64);
        assert!(product <= (MAX_AS_U32 as u64) + 1, OVERFLOW);
        if (sign(num1) != sign(num2)) {
            return neg_from((product as u32))
        };
        from((product as u32))
    }

    // Performs division on two I32 numbers
    public fun div(num1: I32, num2: I32): I32 {
        let result = abs_u32(num1) / abs_u32(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    // Returns the absolute value of an I32 number
    public fun abs(v: I32): I32 {
        if (sign(v) == 0) {
            v
        } else {
            assert!(v.bits > MIN_AS_U32, OVERFLOW);
            I32 {
                bits: u32_neg(v.bits - 1)
            }
        }
    }

    // Returns the absolute value of an I32 number as a u32
    public fun abs_u32(v: I32): u32 {
        if (sign(v) == 0) {
            v.bits
        } else {
            u32_neg(v.bits - 1)
        }
    }

    // Performs modulo operation on two I32 numbers
    public fun mod(v: I32, n: I32): I32 {
        if (sign(v) == 1) {
            neg_from((abs_u32(v) % abs_u32(n)))
        } else {
            from((as_u32(v) % abs_u32(n)))
        }
    }

    // Returns the minimum of two I32 numbers
    public fun min(a: I32, b: I32): I32 {
        if (lt(a, b)) {
            a
        } else {
            b
        }
    }

    // Returns the maximum of two I32 numbers
    public fun max(a: I32, b: I32): I32 {
        if (gt(a, b)) {
            a
        } else {
            b
        }
    }

    // Raises an I32 number to a u32 power
    public fun pow(base: I32, exponent: u32): I32 {
        if (exponent == 0) {
            return from(1)
        };
        let result = from(1);
        let base = base;
        let exp = exponent;
        while (exp > 0) {
            if (exp & 1 == 1) {
                result = mul(result, base);
            };
            base = mul(base, base);
            exp = exp >> 1;
        };
        result
    }

    // Calculates the greatest common divisor of two I32 numbers
    public fun gcd(a: I32, b: I32): I32 {
        let a = abs(a);
        let b = abs(b);
        while (!is_zero(b)) {
            let temp = b;
            b = mod(a, b);
            a = temp;
        };
        a
    }

    // Calculates the least common multiple of two I32 numbers
    public fun lcm(a: I32, b: I32): I32 {
        if (is_zero(a) || is_zero(b)) {
            return zero()
        };
        let gcd_val = gcd(a, b);
        abs(div(mul(a, b), gcd_val))
    }

    // Converts an I32 to u32
    public fun as_u32(v: I32): u32 {
        v.bits
    }

    // Returns the sign of an I32 number (0 for positive, 1 for negative)
    public fun sign(v: I32): u8 {
        ((v.bits >> 31) as u8)
    }

    // Checks if an I32 number is zero
    public fun is_zero(v: I32): bool {
        v.bits == 0
    }

    // Checks if an I32 number is negative
    public fun is_neg(v: I32): bool {
        sign(v) == 1
    }

    // Compares two I32 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I32, num2: I32): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    // Checks if two I32 numbers are equal
    public fun eq(num1: I32, num2: I32): bool {
        num1.bits == num2.bits
    }

    // Checks if the first I32 number is greater than the second
    public fun gt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == GT
    }

    // Checks if the first I32 number is greater than or equal to the second
    public fun gte(num1: I32, num2: I32): bool {
        cmp(num1, num2) >= EQ
    }

    // Checks if the first I32 number is less than the second
    public fun lt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == LT
    }

    // Checks if the first I32 number is less than or equal to the second
    public fun lte(num1: I32, num2: I32): bool {
        cmp(num1, num2) <= EQ
    }

    // Performs bitwise OR on two I32 numbers
    public fun or(num1: I32, num2: I32): I32 {
        I32 {
            bits: (num1.bits | num2.bits)
        }
    }

    // Performs bitwise AND on two I32 numbers
    public fun and(num1: I32, num2: I32): I32 {
        I32 {
            bits: (num1.bits & num2.bits)
        }
    }

    // Helper function to perform bitwise negation on a u32
    fun u32_neg(v: u32): u32 {
        v ^ 0xffffffff
    }

    // Helper function to perform bitwise negation on a u8
    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }


    // Basic Operations Tests
    #[test]
    fun test_from() {
        assert!(as_u32(from(0)) == 0, 0);
        assert!(as_u32(from(10)) == 10, 1);
    }

    #[test]
    #[expected_failure]
    fun test_from_overflow() {
        as_u32(from(MIN_AS_U32));
        as_u32(from(0xffffffff));
    }

    #[test]
    fun test_neg_from() {
        assert!(as_u32(neg_from(0)) == 0, 0);
        assert!(as_u32(neg_from(1)) == 0xffffffff, 1);
        assert!(as_u32(neg_from(0x7fffffff)) == 0x80000001, 2);
        assert!(as_u32(neg_from(MIN_AS_U32)) == MIN_AS_U32, 3);
    }

    #[test]
    #[expected_failure]
    fun test_neg_from_overflow() {
        neg_from(0x80000001);
    }

    // Absolute Value Tests
    #[test]
    fun test_abs() {
        assert!(as_u32(abs(from(10))) == 10u32, 0);
        assert!(as_u32(abs(neg_from(10))) == 10u32, 1);
        assert!(as_u32(abs(neg_from(0))) == 0u32, 2);
        assert!(as_u32(abs(neg_from(0x7fffffff))) == 0x7fffffff, 3);
    }

    #[test]
    #[expected_failure]
    fun test_abs_overflow() {
        abs(neg_from(1 << 31));
    }

    // Addition Tests
    #[test]
    fun test_wrapping_add_positive() {
        assert!(as_u32(wrapping_add(from(0), from(1))) == 1, 0);
        assert!(as_u32(wrapping_add(from(10000), from(99999))) == 109999, 1);
        assert!(as_u32(wrapping_add(from(MAX_AS_U32 - 1), from(1))) == MAX_AS_U32, 2);
    }

    #[test]
    fun test_wrapping_add_negative() {
        assert!(as_u32(wrapping_add(neg_from(1), neg_from(0))) == 0xffffffff, 0);
        assert!(as_u32(wrapping_add(neg_from(10000), neg_from(99999))) == 0xfffe5251, 1);
    }

    #[test]
    fun test_wrapping_add_mixed() {
        assert!(as_u32(wrapping_add(from(10000), neg_from(99999))) == 0xfffea071, 0);
        assert!(as_u32(wrapping_add(from(99999), neg_from(10000))) == 89999, 1);
        assert!(as_u32(wrapping_add(from(MAX_AS_U32), from(1))) == MIN_AS_U32, 2);
    }

    #[test]
    fun test_add() {
        assert!(as_u32(add(from(0), from(1))) == 1, 0);
        assert!(as_u32(add(neg_from(1), from(1))) == 0, 1);
        assert!(as_u32(add(from(MAX_AS_U32 - 1), from(1))) == MAX_AS_U32, 2);
    }

    #[test]
    #[expected_failure]
    fun test_add_overflow() {
        add(from(MAX_AS_U32), from(1));
    }

    #[test]
    #[expected_failure]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U32), neg_from(1));
    }

    // Subtraction Tests
    #[test]
    fun test_wrapping_sub() {
        assert!(as_u32(wrapping_sub(from(1), from(0))) == 1, 0);
        assert!(as_u32(wrapping_sub(from(0), from(1))) == as_u32(neg_from(1)), 1);
        assert!(as_u32(wrapping_sub(from(1), neg_from(1))) == as_u32(from(2)), 2);
        assert!(as_u32(wrapping_sub(from(MAX_AS_U32), from(1))) == as_u32(from(MAX_AS_U32 - 1)), 3);
    }

    #[test]
    fun test_sub() {
        assert!(as_u32(sub(from(1), from(0))) == 1, 0);
        assert!(as_u32(sub(from(0), from(1))) == as_u32(neg_from(1)), 1);
        assert!(as_u32(sub(from(MAX_AS_U32), from(MAX_AS_U32))) == as_u32(from(0)), 2);
    }

    #[test]
    #[expected_failure]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U32), neg_from(1));
    }

    #[test]
    #[expected_failure]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U32), from(1));
    }

    // Multiplication Tests
    #[test]
    fun test_mul() {
        assert!(as_u32(mul(from(10), from(10))) == 100, 0);
        assert!(as_u32(mul(neg_from(10), from(10))) == as_u32(neg_from(100)), 1);
        assert!(as_u32(mul(from(10), neg_from(10))) == as_u32(neg_from(100)), 2);
        assert!(as_u32(mul(from(MIN_AS_U32 / 2), neg_from(2))) == as_u32(neg_from(MIN_AS_U32)), 3);
    }

    #[test]
    #[expected_failure]
    fun test_mul_overflow() {
        mul(from(MIN_AS_U32 / 2), from(3));
    }

    // Division Tests
    #[test]
    fun test_div() {
        assert!(as_u32(div(from(10), from(1))) == 10, 0);
        assert!(as_u32(div(from(10), neg_from(1))) == as_u32(neg_from(10)), 1);
        assert!(as_u32(div(neg_from(10), neg_from(1))) == as_u32(from(10)), 2);
        assert!(as_u32(div(neg_from(MIN_AS_U32), from(1))) == MIN_AS_U32, 3);
    }

    #[test]
    #[expected_failure]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U32), neg_from(1));
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
        assert!(cmp(neg_from(MIN_AS_U32), from(MAX_AS_U32)) == LT, 3);
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
        assert!(eq(min(from(MAX_AS_U32), from(0)), from(0)), 3);
        assert!(eq(min(neg_from(MIN_AS_U32), from(0)), neg_from(MIN_AS_U32)), 4);
    }

    // Maximum Tests
    #[test]
    fun test_max() {
        assert!(eq(max(from(10), from(5)), from(10)), 0);
        assert!(eq(max(from(0), neg_from(5)), from(0)), 1);
        assert!(eq(max(neg_from(10), neg_from(5)), neg_from(5)), 2);
        assert!(eq(max(from(MAX_AS_U32), from(0)), from(MAX_AS_U32)), 3);
        assert!(eq(max(neg_from(MIN_AS_U32), from(0)), from(0)), 4);
    }

    #[test]
    fun test_pow() {
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(from(3), 4), from(81)), 1);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 2);
        assert!(eq(pow(neg_from(2), 2), from(4)), 3);
    }

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
        assert!(eq(lcm(neg_from(12), from(18)), from(36)), 0);
        assert!(eq(lcm(from(5), from(7)), from(35)), 1);
        assert!(eq(lcm(from(3), from(6)), from(6)), 2);
        assert!(eq(lcm(from(0), from(5)), zero()), 3);
    }
}