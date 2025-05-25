module move_int::i32 {

    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    /// min number that a I32 could represent = (1 followed by 31 0s) = 1 << 31
    const BITS_MIN_I32: u32 = 1 << 31;

    /// max number that a I32 could represent = (0 followed by 31 1s) = (1 << 31) - 1
    const BITS_MAX_I32: u32 = 0x7fffffff;

    /// 32 1s
    const MASK_U32: u32 = 0xffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I32 has copy, drop, store {
        bits: u32
    }

    /// Creates an I32 from a u32, asserting that it's not greater than the maximum positive value
    public fun from(v: u32): I32 {
        assert!(v <= BITS_MAX_I32, OVERFLOW);
        I32 { bits: v }
    }

    /// Creates a negative I32 from a u32, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u32): I32 {
        assert!(v <= BITS_MIN_I32, OVERFLOW);
        I32 { bits: twos_complement(v) }
    }

    /// Performs wrapping addition on two I32 numbers
    public fun wrapping_add(num1: I32, num2: I32): I32 {
        I32 { bits: (((num1.bits as u64) + (num2.bits as u64)) & (MASK_U32 as u64) as u32) }
    }

    /// Performs checked addition on two I32 numbers, abort on overflow
    public fun add(num1: I32, num2: I32): I32 {
        let sum = wrapping_add(num1, num2);
        // overflow only if: (1) postive + postive = negative, OR (2) negative + negative = positive
        let is_num1_neg = is_neg(num1);
        let is_num2_neg = is_neg(num2);
        let is_sum_neg = is_neg(sum);
        let overflow = (is_num1_neg && is_num2_neg && !is_sum_neg) || (!is_num1_neg && !is_num2_neg && is_sum_neg);
        assert!(!overflow, OVERFLOW);
        sum
    }

    /// Performs wrapping subtraction on two I32 numbers
    public fun wrapping_sub(num1: I32, num2: I32): I32 {
        wrapping_add(num1, I32 { bits: twos_complement(num2.bits) })
    }

    /// Performs checked subtraction on two I32 numbers, asserting on overflow
    public fun sub(num1: I32, num2: I32): I32 {
        add(num1, I32 { bits: twos_complement(num2.bits) })
    }

    /// Performs multiplication on two I32 numbers
    public fun mul(num1: I32, num2: I32): I32 {
        let product = (abs_u32(num1) as u64) * (abs_u32(num2) as u64);
        if (sign(num1) != sign(num2)) {
            assert!(product <= (BITS_MIN_I32 as u64), OVERFLOW);
            neg_from((product as u32))
        } else {
            assert!(product <= (BITS_MAX_I32 as u64), OVERFLOW);
            from((product as u32))
        }
    }

    /// Performs division on two I32 numbers
    /// Note that we mimic the behavior of solidity int division that it rounds towards 0 rather than rounds down
    /// - rounds towards 0: (-4) / 3 = -(4 / 3) = -1 (remainder = -1)
    /// - rounds down: (-4) / 3 = -2 (remainder = 2)
    public fun div(num1: I32, num2: I32): I32 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u32(num1) / abs_u32(num2);
        if (sign(num1) != sign(num2)) neg_from(result)
        else from(result)
    }

    /// Performs modulo on two I32 numbers
    /// a mod b = a - b * (a / b)
    public fun mod(num1: I32, num2: I32): I32 {
        let quotient = div(num1, num2);
        sub(num1, mul(num2, quotient))
    }

    /// Returns the absolute value of an I32 number
    public fun abs(v: I32): I32 {
        let bits = if (sign(v) == 0) { v.bits }
        else {
            assert!(v.bits > BITS_MIN_I32, OVERFLOW);
            twos_complement(v.bits)
        };
        I32 { bits }
    }

    /// Returns the absolute value of an I32 number as a u32
    public fun abs_u32(v: I32): u32 {
        if (sign(v) == 0) v.bits
        else twos_complement(v.bits)
    }

    /// Returns the minimum of two I32 numbers
    public fun min(a: I32, b: I32): I32 {
        if (lt(a, b)) a else b
    }

    /// Returns the maximum of two I32 numbers
    public fun max(a: I32, b: I32): I32 {
        if (gt(a, b)) a else b
    }

    /// Raises an I32 number to a u32 power
    public fun pow(base: I32, exponent: u32): I32 {
        if (exponent == 0) {
            return from(1)
        };
        let result = from(1);
        while (exponent > 0) {
            if (exponent & 1 == 1) {
                result = mul(result, base);
            };
            base = mul(base, base);
            exponent >>= 1;
        };
        result
    }

    /// Creates an I32 from a u32 without any checks
    public fun pack(v: u32): I32 {
        I32 { bits: v }
    }

    /// Get internal bits of I32
    public fun unpack(v: I32): u32 {
        v.bits
    }

    /// Returns the sign of an I32 number (0 for positive, 1 for negative)
    public fun sign(v: I32): u8 {
        ((v.bits >> 31) as u8)
    }

    /// Creates and returns an I32 representing zero
    public fun zero(): I32 {
        I32 { bits: 0 }
    }

    /// Checks if an I32 number is zero
    public fun is_zero(v: I32): bool {
        v.bits == 0
    }

    /// Checks if an I32 number is negative
    public fun is_neg(v: I32): bool {
        sign(v) == 1
    }

    /// Compares two I32 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I32, num2: I32): u8 {
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

    /// Checks if two I32 numbers are equal
    public fun eq(num1: I32, num2: I32): bool {
        cmp(num1, num2) == EQ
    }

    /// Checks if the first I32 number is greater than the second
    public fun gt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == GT
    }

    /// Checks if the first I32 number is greater than or equal to the second
    public fun gte(num1: I32, num2: I32): bool {
        cmp(num1, num2) >= EQ
    }

    /// Checks if the first I32 number is less than the second
    public fun lt(num1: I32, num2: I32): bool {
        cmp(num1, num2) == LT
    }

    /// Checks if the first I32 number is less than or equal to the second
    public fun lte(num1: I32, num2: I32): bool {
        cmp(num1, num2) <= EQ
    }

    #[deprecated]
    /// Performs bitwise OR on two I32 numbers
    public fun or(num1: I32, num2: I32): I32 {
        I32 { bits: (num1.bits | num2.bits) }
    }

    #[deprecated]
    /// Performs bitwise AND on two I32 numbers
    public fun and(num1: I32, num2: I32): I32 {
        I32 { bits: (num1.bits & num2.bits) }
    }

    #[deprecated]
    public fun from_u32(v: u32): I32 {
        pack(v)
    }

    #[deprecated]
    // Converts an I32 to u32
    public fun as_u32(v: I32): u32 {
        unpack(v)
    }

    /// Two's complement in order to dervie negative representation of bits
    /// It is overflow-proof because we hardcode 2's complement of 0 to be 0
    /// Which is fine for our specific use case
    fun twos_complement(v: u32): u32 {
        if (v == 0) 0
        else (v ^ MASK_U32) + 1
    }
}
