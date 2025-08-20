module move_int::i256 {
    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    const BITS_MIN_I256: u256 = 1 << 255;
    const BITS_MAX_I256: u256 =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    const MASK_U256: u256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I256 has copy, drop, store {
        bits: u256
    }

    public fun from(v: u256): I256 {
        assert!(v <= BITS_MAX_I256, OVERFLOW);
        I256 { bits: v }
    }

    public fun neg_from(v: u256): I256 {
        assert!(v <= BITS_MIN_I256, OVERFLOW);
        I256 { bits: twos_complement(v) }
    }

    public fun neg(v: I256): I256 {
        if (is_neg(v)) { abs(v) }
        else {
            neg_from(v.bits)
        }
    }

    /// Note: implementation is not performant
    public fun wrapping_add(num1: I256, num2: I256): I256 {
        let sum = num1.bits ^ num2.bits;
        let carry = (num1.bits & num2.bits) << 1;
        while (carry != 0) {
            let a = sum;
            let b = carry;
            sum = a ^ b;
            carry = (a & b) << 1;
        };
        I256 { bits: sum }
    }

    public fun add(num1: I256, num2: I256): I256 {
        let (sum, overflow) = overflowing_add(num1, num2);
        assert!(!overflow, OVERFLOW);
        sum
    }

    public fun overflowing_add(num1: I256, num2: I256): (I256, bool) {
        let sum = wrapping_add(num1, num2);
        let is_num1_neg = is_neg(num1);
        let is_num2_neg = is_neg(num2);
        let is_sum_neg = is_neg(sum);
        let overflow = (is_num1_neg && is_num2_neg && !is_sum_neg) || (!is_num1_neg && !is_num2_neg && is_sum_neg);
        (sum, overflow)
    }

    public fun wrapping_sub(num1: I256, num2: I256): I256 {
        wrapping_add(num1, I256 { bits: twos_complement(num2.bits) })
    }

    public fun sub(num1: I256, num2: I256): I256 {
        add(num1, I256 { bits: twos_complement(num2.bits) })
    }

    public fun overflowing_sub(num1: I256, num2: I256): (I256, bool) {
        let sub_num = I256 { bits: twos_complement(num2.bits) };
        overflowing_add(num1, sub_num)
    }

    public fun mul(num1: I256, num2: I256): I256 {
        let product = abs_u256(num1) * abs_u256(num2);
        if (sign(num1) != sign(num2)) {
            neg_from(product)
        } else {
            from(product)
        }
    }

    public fun div(num1: I256, num2: I256): I256 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u256(num1) / abs_u256(num2);
        if (sign(num1) != sign(num2)) neg_from(result)
        else from(result)
    }

    public fun mod(num1: I256, num2: I256): I256 {
        let quotient = div(num1, num2);
        sub(num1, mul(num2, quotient))
    }

    public fun abs(v: I256): I256 {
        let bits = if (sign(v) == 0) { v.bits }
        else {
            assert!(v.bits > BITS_MIN_I256, OVERFLOW);
            twos_complement(v.bits)
        };
        I256 { bits }
    }

    public fun abs_u256(v: I256): u256 {
        if (sign(v) == 0) v.bits
        else twos_complement(v.bits)
    }

    public fun min(a: I256, b: I256): I256 {
        if (lt(a, b)) a else b
    }

    public fun max(a: I256, b: I256): I256 {
        if (gt(a, b)) a else b
    }

    public fun pow(base: I256, exponent: u64): I256 {
        if (exponent == 0) {
            return from(1)
        };
        let result = from(1);
        while (exponent > 0) {
            if (exponent & 1 == 1) {
                result = mul(result, base);
            };
            base = mul(base, base);
            exponent = exponent >> 1;
        };
        result
    }

    public fun is_zero(v: I256): bool {
        v.bits == 0
    }

    /// Creates and returns an I256 representing zero
    public fun zero(): I256 {
        I256 { bits: 0 }
    }

    /// Creates an I256 from a u256 without any checks
    public fun pack(v: u256): I256 {
        I256 { bits: v }
    }

    #[deprecated]
    public fun as_u256(v: I256): u256 {
        unpack(v)
    }

    public fun sign(v: I256): u8 {
        ((v.bits >> 255) as u8)
    }

    public fun is_neg(v: I256): bool {
        sign(v) == 1
    }

    public fun cmp(num1: I256, num2: I256): u8 {
        if (num1.bits == num2.bits) return EQ;
        let sign1 = sign(num1);
        let sign2 = sign(num2);
        if (sign1 > sign2) return LT;
        if (sign1 < sign2) return GT;
        if (num1.bits > num2.bits) {
            return GT
        } else {
            return LT
        }
    }

    public fun eq(num1: I256, num2: I256): bool {
        cmp(num1, num2) == EQ
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

    #[deprecated]
    public fun or(num1: I256, num2: I256): I256 {
        I256 { bits: (num1.bits | num2.bits) }
    }

    #[deprecated]
    public fun and(num1: I256, num2: I256): I256 {
        I256 { bits: (num1.bits & num2.bits) }
    }

    /// Get internal bits of I256
    public fun unpack(v: I256): u256 {
        v.bits
    }

    /// Two's complement in order to dervie negative representation of bits
    /// It is overflow-proof because we hardcode 2's complement of 0 to be 0
    /// Which is fine for our specific use case
    fun twos_complement(v: u256): u256 {
        if (v == 0) 0
        else (v ^ MASK_U256) + 1
    }
}
