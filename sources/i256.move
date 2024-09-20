module move_int::i256 {
    use std::error;

    const OVERFLOW: u64 = 0;

    const MIN_AS_U256: u256 = 1 << 255;
    const MAX_AS_U256: u256 = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I256 has copy, drop, store {
        bits: u256
    }

    public fun zero(): I256 {
        I256 {
            bits: 0
        }
    }

    public fun from(v: u256): I256 {
        assert!(v <= MAX_AS_U256, error::invalid_argument(OVERFLOW));
        I256 {
            bits: v
        }
    }

    public fun neg_from(v: u256): I256 {
        assert!(v <= MIN_AS_U256, error::invalid_argument(OVERFLOW));
        if (v == 0) {
            I256 {
                bits: v
            }
        } else {
            I256 {
                bits: (u256_neg(v) + 1) | (1 << 255)
            }
        }
    }

    public fun neg(v: I256): I256 {
        if (is_neg(v)) {
            abs(v)
        } else {
            neg_from(v.bits)
        }
    }

    public fun wrapping_add(num1: I256, num2: I256): I256 {
        let sum = num1.bits ^ num2.bits;
        let carry = (num1.bits & num2.bits) << 1;
        while (carry != 0) {
            let a = sum;
            let b = carry;
            sum = a ^ b;
            carry = (a & b) << 1;
        };
        I256 {
            bits: sum
        }
    }

    public fun add(num1: I256, num2: I256): I256 {
        let sum = wrapping_add(num1, num2);
        let overflow = (sign(num1) & sign(num2) & u8_neg(sign(sum))) + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        assert!(overflow == 0, error::invalid_argument(OVERFLOW));
        sum
    }

    public fun overflowing_add(num1: I256, num2: I256): (I256, bool) {
        let sum = wrapping_add(num1, num2);
        let overflow = (sign(num1) & sign(num2) & u8_neg(sign(sum))) + (u8_neg(sign(num1)) & u8_neg(sign(num2)) & sign(sum));
        (sum, overflow != 0)
    }

    public fun wrapping_sub(num1: I256, num2: I256): I256 {
        let sub_num = wrapping_add(I256 {
            bits: u256_neg(num2.bits)
        }, from(1));
        wrapping_add(num1, sub_num)
    }

    public fun sub(num1: I256, num2: I256): I256 {
        let sub_num = wrapping_add(I256 {
            bits: u256_neg(num2.bits)
        }, from(1));
        add(num1, sub_num)
    }

    public fun overflowing_sub(num1: I256, num2: I256): (I256, bool) {
        let sub_num = wrapping_add(I256 {
            bits: u256_neg(num2.bits)
        }, from(1));
        let sum = wrapping_add(num1, sub_num);
        let overflow = (sign(num1) & sign(sub_num) & u8_neg(sign(sum))) + (u8_neg(sign(num1)) & u8_neg(sign(sub_num)) & sign(sum));
        (sum, overflow != 0)
    }

    public fun mul(num1: I256, num2: I256): I256 {
        let product = abs_u256(num1) * abs_u256(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(product)
        };
        return from(product)
    }

    public fun div(num1: I256, num2: I256): I256 {
        let result = abs_u256(num1) / abs_u256(num2);
        if (sign(num1) != sign(num2)) {
            return neg_from(result)
        };
        return from(result)
    }

    public fun abs(v: I256): I256 {
        if (sign(v) == 0) {
            v
        } else {
            assert!(v.bits > MIN_AS_U256, error::invalid_argument(OVERFLOW));
            I256 {
                bits: u256_neg(v.bits - 1)
            }
        }
    }

    public fun abs_u256(v: I256): u256 {
        if (sign(v) == 0) {
            v.bits
        } else {
            u256_neg(v.bits - 1)
        }
    }

    public fun min(a: I256, b: I256): I256 {
        if (lt(a, b)) {
            a
        } else {
            b
        }
    }

    public fun max(a: I256, b: I256): I256 {
        if (gt(a, b)) {
            a
        } else {
            b
        }
    }

    public fun pow(base: I256, exponent: u64): I256 {
        let result = from(1);
        let b = base;
        let exp = exponent;

        while (exp > 0) {
            if (exp & 1 == 1) {
                result = mul(result, b);
            };
            b = mul(b, b);
            exp = exp >> 1;
        };
        result
    }

    public fun is_zero(v: I256): bool {
        v.bits == 0
    }

    public fun as_u256(v: I256): u256 {
        v.bits
    }

    public fun sign(v: I256): u8 {
        ((v.bits >> 255) as u8)
    }

    public fun is_neg(v: I256): bool {
        sign(v) == 1
    }

    public fun cmp(num1: I256, num2: I256): u8 {
        if (num1.bits == num2.bits) return EQ;
        if (sign(num1) > sign(num2)) return LT;
        if (sign(num1) < sign(num2)) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    public fun eq(num1: I256, num2: I256): bool {
        num1.bits == num2.bits
    }

    public fun gt(num1: I256, num2: I256): bool {
        cmp(num1, num2) == GT
    }

    public fun gte(num1: I256, num2: I256): bool {
        cmp(num1, num2) >= EQ
    }

    public fun lt(num1: I256, num2: I256): bool {
        cmp(num1, num2) == LT
    }

    public fun lte(num1: I256, num2: I256): bool {
        cmp(num1, num2) <= EQ
    }

    public fun or(num1: I256, num2: I256): I256 {
        I256 {
            bits: (num1.bits | num2.bits)
        }
    }

    public fun and(num1: I256, num2: I256): I256 {
        I256 {
            bits: (num1.bits & num2.bits)
        }
    }

    fun u256_neg(v: u256): u256 {
        v ^ 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    }

    fun u8_neg(v: u8): u8 {
        v ^ 0xff
    }

    #[test]
    fun test_from_ok() {
        assert!(from(0).bits == 0, 0);
        assert!(from(10).bits == 10, 1);
        assert!(from(MAX_AS_U256).bits == MAX_AS_U256, 2);
    }

    #[test]
    #[expected_failure]
    fun test_from_overflow() {
        from(MIN_AS_U256);
    }

    #[test]
    fun test_neg_from() {
        assert!(neg_from(0).bits == 0, 0);
        assert!(neg_from(1).bits == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 1);
        assert!(neg_from(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff).bits == 0x8000000000000000000000000000000000000000000000000000000000000001, 2);
        assert!(neg_from(MIN_AS_U256).bits == MIN_AS_U256, 3);
    }

    #[test]
    #[expected_failure]
    fun test_neg_from_overflow() {
        neg_from(0x8000000000000000000000000000000000000000000000000000000000000001);
    }

    #[test]
    fun test_abs() {
        assert!(abs(from(10)).bits == 10, 0);
        assert!(abs(neg_from(10)).bits == 10, 1);
        assert!(abs(neg_from(0)).bits == 0, 2);
        assert!(abs(neg_from(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)).bits == 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 3);
        // assert!(abs(neg_from(MIN_AS_U256)).bits == MIN_AS_U256, 4);
    }

    #[test]
    #[expected_failure]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U256));
    }

    #[test]
    fun test_wrapping_add() {
        assert!(wrapping_add(from(0), from(1)).bits == 1, 0);
        assert!(wrapping_add(from(1), from(0)).bits == 1, 1);
        assert!(wrapping_add(from(10000), from(99999)).bits == 109999, 2);
        assert!(wrapping_add(from(99999), from(10000)).bits == 109999, 3);
        assert!(wrapping_add(from(MAX_AS_U256 - 1), from(1)).bits == MAX_AS_U256, 4);
        assert!(wrapping_add(from(0), from(0)).bits == 0, 5);

        assert!(wrapping_add(neg_from(0), neg_from(0)).bits == 0, 6);
        assert!(wrapping_add(neg_from(1), neg_from(0)).bits == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 7);
        assert!(wrapping_add(neg_from(0), neg_from(1)).bits == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 8);
        assert!(wrapping_add(neg_from(10000), neg_from(99999)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5251, 9);
        assert!(wrapping_add(neg_from(99999), neg_from(10000)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5251, 10);
        assert!(wrapping_add(neg_from(MIN_AS_U256 - 1), neg_from(1)).bits == MIN_AS_U256, 11);

        assert!(wrapping_add(from(0), neg_from(0)).bits == 0, 12);
        assert!(wrapping_add(neg_from(0), from(0)).bits == 0, 13);
        assert!(wrapping_add(neg_from(1), from(1)).bits == 0, 14);
        assert!(wrapping_add(from(1), neg_from(1)).bits == 0, 15);
        assert!(wrapping_add(from(10000), neg_from(99999)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea071, 16);
        assert!(wrapping_add(from(99999), neg_from(10000)).bits == 89999, 17);
        assert!(wrapping_add(neg_from(MIN_AS_U256), from(1)).bits == 0x8000000000000000000000000000000000000000000000000000000000000001, 18);
        assert!(wrapping_add(from(MAX_AS_U256), neg_from(1)).bits == MAX_AS_U256 - 1, 19);

        assert!(wrapping_add(from(MAX_AS_U256), from(1)).bits == MIN_AS_U256, 20);
    }

    #[test]
    fun test_add() {
        assert!(add(from(0), from(0)).bits == 0, 0);
        assert!(add(from(0), from(1)).bits == 1, 1);
        assert!(add(from(1), from(0)).bits == 1, 2);
        assert!(add(from(10000), from(99999)).bits == 109999, 3);
        assert!(add(from(99999), from(10000)).bits == 109999, 4);
        assert!(add(from(MAX_AS_U256 - 1), from(1)).bits == MAX_AS_U256, 5);

        assert!(add(neg_from(0), neg_from(0)).bits == 0, 6);
        assert!(add(neg_from(1), neg_from(0)).bits == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 7);
        assert!(add(neg_from(0), neg_from(1)).bits == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, 8);
        assert!(add(neg_from(10000), neg_from(99999)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5251, 9);
        assert!(add(neg_from(99999), neg_from(10000)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5251, 10);
        assert!(add(neg_from(MIN_AS_U256 - 1), neg_from(1)).bits == MIN_AS_U256, 11);

        assert!(add(from(0), neg_from(0)).bits == 0, 12);
        assert!(add(neg_from(0), from(0)).bits == 0, 13);
        assert!(add(neg_from(1), from(1)).bits == 0, 14);
        assert!(add(from(1), neg_from(1)).bits == 0, 15);
        assert!(add(from(10000), neg_from(99999)).bits == 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffea071, 16);
        assert!(add(from(99999), neg_from(10000)).bits == 89999, 17);
        assert!(add(neg_from(MIN_AS_U256), from(1)).bits == 0x8000000000000000000000000000000000000000000000000000000000000001, 18);
        assert!(add(from(MAX_AS_U256), neg_from(1)).bits == MAX_AS_U256 - 1, 19);
    }

    #[test]
    fun test_overflowing_add() {
        let (result, overflow) = overflowing_add(from(MAX_AS_U256), neg_from(1));
        assert!(overflow == false && result.bits == MAX_AS_U256 - 1, 1);
        let (_, overflow) = overflowing_add(from(MAX_AS_U256), from(1));
        assert!(overflow == true, 2);
        let (_, overflow) = overflowing_add(neg_from(MIN_AS_U256), neg_from(1));
        assert!(overflow == true, 3);
    }

    #[test]
    #[expected_failure]
    fun test_add_overflow() {
        add(from(MAX_AS_U256), from(1));
    }

    #[test]
    #[expected_failure]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U256), neg_from(1));
    }

    #[test]
    fun test_wrapping_sub() {
        assert!(wrapping_sub(from(0), from(0)).bits == 0, 0);
        assert!(wrapping_sub(from(1), from(0)).bits == 1, 1);
        assert!(wrapping_sub(from(0), from(1)).bits == neg_from(1).bits, 2);
        assert!(wrapping_sub(from(1), from(1)).bits == 0, 3);
        assert!(wrapping_sub(from(1), neg_from(1)).bits == 2, 4);
        assert!(wrapping_sub(neg_from(1), from(1)).bits == neg_from(2).bits, 5);
        assert!(wrapping_sub(from(1000000), from(1)).bits == 999999, 6);
        assert!(wrapping_sub(neg_from(1000000), neg_from(1)).bits == neg_from(999999).bits, 7);
        assert!(wrapping_sub(from(1), from(1000000)).bits == neg_from(999999).bits, 8);
        assert!(wrapping_sub(from(MAX_AS_U256), from(MAX_AS_U256)).bits == 0, 9);
        assert!(wrapping_sub(from(MAX_AS_U256), from(1)).bits == MAX_AS_U256 - 1, 10);
        assert!(wrapping_sub(from(MAX_AS_U256), neg_from(1)).bits == neg_from(MIN_AS_U256).bits, 11);
        assert!(wrapping_sub(neg_from(MIN_AS_U256), neg_from(1)).bits == neg_from(MIN_AS_U256 - 1).bits, 12);
        assert!(wrapping_sub(neg_from(MIN_AS_U256), from(1)).bits == MAX_AS_U256, 13);
    }

    #[test]
    fun test_sub() {
        assert!(sub(from(0), from(0)).bits == 0, 0);
        assert!(sub(from(1), from(0)).bits == 1, 1);
        assert!(sub(from(0), from(1)).bits == neg_from(1).bits, 2);
        assert!(sub(from(1), from(1)).bits == 0, 3);
        assert!(sub(from(1), neg_from(1)).bits == 2, 4);
        assert!(sub(neg_from(1), from(1)).bits == neg_from(2).bits, 5);
        assert!(sub(from(1000000), from(1)).bits == 999999, 6);
        assert!(sub(neg_from(1000000), neg_from(1)).bits == neg_from(999999).bits, 7);
        assert!(sub(from(1), from(1000000)).bits == neg_from(999999).bits, 8);
        assert!(sub(from(MAX_AS_U256), from(MAX_AS_U256)).bits == 0, 9);
        assert!(sub(from(MAX_AS_U256), from(1)).bits == MAX_AS_U256 - 1, 10);
        assert!(sub(neg_from(MIN_AS_U256), neg_from(1)).bits == neg_from(MIN_AS_U256 - 1).bits, 11);
    }

    #[test]
    fun test_overflowing_sub() {
        let (result, overflowing) = overflowing_sub(from(MAX_AS_U256), from(1));
        assert!(overflowing == false && result.bits == MAX_AS_U256 - 1, 1);

        let (_, overflowing) = overflowing_sub(neg_from(MIN_AS_U256), from(1));
        assert!(overflowing == true, 2);

        let (_, overflowing) = overflowing_sub(from(MAX_AS_U256), neg_from(1));
        assert!(overflowing == true, 3);
    }

    #[test]
    #[expected_failure]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U256), neg_from(1));
    }

    #[test]
    #[expected_failure]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U256), from(1));
    }

    #[test]
    fun test_mul() {
        assert!(mul(from(1), from(1)).bits == 1, 0);
        assert!(mul(from(10), from(10)).bits == 100, 1);
        assert!(mul(from(100), from(100)).bits == 10000, 2);
        assert!(mul(from(10000), from(10000)).bits == 100000000, 3);

        assert!(mul(neg_from(1), from(1)).bits == neg_from(1).bits, 4);
        assert!(mul(neg_from(10), from(10)).bits == neg_from(100).bits, 5);
        assert!(mul(neg_from(100), from(100)).bits == neg_from(10000).bits, 6);
        assert!(mul(neg_from(10000), from(10000)).bits == neg_from(100000000).bits, 7);

        assert!(mul(from(1), neg_from(1)).bits == neg_from(1).bits, 8);
        assert!(mul(from(10), neg_from(10)).bits == neg_from(100).bits, 9);
        assert!(mul(from(100), neg_from(100)).bits == neg_from(10000).bits, 10);
        assert!(mul(from(10000), neg_from(10000)).bits == neg_from(100000000).bits, 11);
        assert!(mul(from(MIN_AS_U256/2), neg_from(2)).bits == neg_from(MIN_AS_U256).bits, 12);
    }

    #[test]
    #[expected_failure]
    fun test_mul_overflow() {
        mul(from(MIN_AS_U256/2), from(3));
    }

    #[test]
    fun test_div() {
        assert!(div(from(0), from(1)).bits == 0, 0);
        assert!(div(from(10), from(1)).bits == 10, 1);
        assert!(div(from(10), neg_from(1)).bits == neg_from(10).bits, 2);
        assert!(div(neg_from(10), neg_from(1)).bits == from(10).bits, 3);
        assert!(div(neg_from(MIN_AS_U256), from(1)).bits == MIN_AS_U256, 5);
    }

    #[test]
    #[expected_failure]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U256), neg_from(1));
    }

    #[test]
    fun test_sign() {
        assert!(sign(neg_from(10)) == 1u8, 0);
        assert!(sign(from(10)) == 0u8, 1);
        assert!(sign(from(0)) == 0u8, 2);
        assert!(sign(neg_from(MIN_AS_U256)) == 1u8, 3);
        assert!(sign(from(MAX_AS_U256)) == 0u8, 4);
    }

    #[test]
    fun test_cmp() {
        assert!(cmp(from(1), from(0)) == GT, 0);
        assert!(cmp(from(0), from(1)) == LT, 1);
        assert!(cmp(from(1), from(1)) == EQ, 2);

        assert!(cmp(from(0), neg_from(1)) == GT, 3);
        assert!(cmp(neg_from(0), neg_from(1)) == GT, 4);
        assert!(cmp(neg_from(1), neg_from(0)) == LT, 5);

        assert!(cmp(neg_from(MIN_AS_U256), from(MAX_AS_U256)) == LT, 6);
        assert!(cmp(from(MAX_AS_U256), neg_from(MIN_AS_U256)) == GT, 7);

        assert!(cmp(from(MAX_AS_U256), from(MAX_AS_U256-1)) == GT, 8);
        assert!(cmp(from(MAX_AS_U256-1), from(MAX_AS_U256)) == LT, 9);

        assert!(cmp(neg_from(MIN_AS_U256), neg_from(MIN_AS_U256-1)) == LT, 10);
        assert!(cmp(neg_from(MIN_AS_U256-1), neg_from(MIN_AS_U256)) == GT, 11);
    }

    #[test]
    fun test_min_max() {
        assert!(eq(min(from(1), from(2)), from(1)), 0);
        assert!(eq(min(neg_from(1), from(1)), neg_from(1)), 1);
        assert!(eq(max(from(1), from(2)), from(2)), 2);
        assert!(eq(max(neg_from(1), from(1)), from(1)), 3);
        assert!(eq(min(from(MAX_AS_U256), from(0)), from(0)), 4);
        assert!(eq(max(neg_from(MIN_AS_U256), from(0)), from(0)), 5);
    }

    #[test]
    fun test_is_zero_positive() {
        assert!(is_zero(from(0)), 0);
        assert!(!is_zero(from(1)), 1);
        assert!(!is_zero(neg_from(1)), 2);
    }

    #[test]
    fun test_binary_pow() {
        assert!(eq(pow(from(2), 10), from(1024)), 0);
        assert!(eq(pow(from(3), 4), from(81)), 1);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 2);
        assert!(eq(pow(neg_from(2), 4), from(16)), 3);
    }

    #[test]
    fun test_castdown() {
        assert!((1u256 as u128) == 1u128, 0);
        assert!((1u256 as u64) == 1u64, 1);
        assert!((1u256 as u32) == 1u32, 2);
        assert!((1u256 as u16) == 1u16, 3);
        assert!((1u256 as u8) == 1u8, 4);
    }

}