module move_int::i16 {

    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    /// min number that a I16 could represent = (1 followed by 15 0s) = 1 << 15
    const BITS_MIN_I16: u16 = 1 << 15;

    /// max number that a I16 could represent = (0 followed by 15 1s) = (1 << 15) - 1
    const BITS_MAX_I16: u16 = 0x7fff;

    /// 16 1s
    const MASK_U16: u16 = 0xffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I16 has copy, drop, store {
        bits: u16
    }

    /// Creates an I16 from a u16, asserting that it's not greater than the maximum positive value
    public fun from(v: u16): I16 {
        assert!(v <= BITS_MAX_I16, OVERFLOW);
        I16 { bits: v }
    }

    /// Creates a negative I16 from a u16, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u16): I16 {
        assert!(v <= BITS_MIN_I16, OVERFLOW);
        I16 { bits: twos_complement(v) }
    }

    /// Performs wrapping addition on two I16 numbers
    public fun wrapping_add(num1: I16, num2: I16): I16 {
        I16 { bits: (((num1.bits as u32) + (num2.bits as u32)) & (MASK_U16 as u32) as u16) }
    }

    /// Performs checked addition on two I16 numbers, abort on overflow
    public fun add(num1: I16, num2: I16): I16 {
        let sum = wrapping_add(num1, num2);
        // overflow only if: (1) postive + postive = negative, OR (2) negative + negative = positive
        let is_num1_neg = is_neg(num1);
        let is_num2_neg = is_neg(num2);
        let is_sum_neg = is_neg(sum);
        let overflow = (is_num1_neg && is_num2_neg && !is_sum_neg) || (!is_num1_neg && !is_num2_neg && is_sum_neg);
        assert!(!overflow, OVERFLOW);
        sum
    }

    /// Performs wrapping subtraction on two I16 numbers
    public fun wrapping_sub(num1: I16, num2: I16): I16 {
        wrapping_add(num1, I16 { bits: twos_complement(num2.bits) })
    }

    /// Performs checked subtraction on two I16 numbers, asserting on overflow
    public fun sub(num1: I16, num2: I16): I16 {
        add(num1, I16 { bits: twos_complement(num2.bits) })
    }

    /// Performs multiplication on two I16 numbers
    public fun mul(num1: I16, num2: I16): I16 {
        let product = (abs_u16(num1) as u32) * (abs_u16(num2) as u32);
        if (sign(num1) != sign(num2)) {
            assert!(product <= (BITS_MIN_I16 as u32), OVERFLOW);
            neg_from((product as u16))
        } else {
            assert!(product <= (BITS_MAX_I16 as u32), OVERFLOW);
            from((product as u16))
        }
    }

    /// Performs division on two I16 numbers
    /// Note that we mimic the behavior of solidity int division that it rounds towards 0 rather than rounds down
    /// - rounds towards 0: (-4) / 3 = -(4 / 3) = -1 (remainder = -1)
    /// - rounds down: (-4) / 3 = -2 (remainder = 2)
    public fun div(num1: I16, num2: I16): I16 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u16(num1) / abs_u16(num2);
        if (sign(num1) != sign(num2)) neg_from(result)
        else from(result)
    }

    /// Performs modulo on two I16 numbers
    /// a mod b = a - b * (a / b)
    public fun mod(num1: I16, num2: I16): I16 {
        let quotient = div(num1, num2);
        sub(num1, mul(num2, quotient))
    }

    /// Returns the absolute value of an I16 number
    public fun abs(v: I16): I16 {
        let bits = if (sign(v) == 0) { v.bits }
        else {
            assert!(v.bits > BITS_MIN_I16, OVERFLOW);
            twos_complement(v.bits)
        };
        I16 { bits }
    }

    /// Returns the absolute value of an I16 number as a u16
    public fun abs_u16(v: I16): u16 {
        if (sign(v) == 0) v.bits
        else twos_complement(v.bits)
    }

    /// Returns the minimum of two I16 numbers
    public fun min(a: I16, b: I16): I16 {
        if (lt(a, b)) a else b
    }

    /// Returns the maximum of two I16 numbers
    public fun max(a: I16, b: I16): I16 {
        if (gt(a, b)) a else b
    }

    /// Raises an I16 number to a u16 power
    public fun pow(base: I16, exponent: u16): I16 {
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

    /// Creates an I16 from a u16 without any checks
    public fun pack(v: u16): I16 {
        I16 { bits: v }
    }

    /// Get internal bits of I16
    public fun unpack(v: I16): u16 {
        v.bits
    }

    /// Returns the sign of an I16 number (0 for positive, 1 for negative)
    public fun sign(v: I16): u8 {
        ((v.bits >> 15) as u8)
    }

    /// Creates and returns an I16 representing zero
    public fun zero(): I16 {
        I16 { bits: 0 }
    }

    /// Checks if an I16 number is zero
    public fun is_zero(v: I16): bool {
        v.bits == 0
    }

    /// Checks if an I16 number is negative
    public fun is_neg(v: I16): bool {
        sign(v) == 1
    }

    /// Compares two I16 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I16, num2: I16): u8 {
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

    /// Checks if two I16 numbers are equal
    public fun eq(num1: I16, num2: I16): bool {
        cmp(num1, num2) == EQ
    }

    /// Checks if the first I16 number is greater than the second
    public fun gt(num1: I16, num2: I16): bool {
        cmp(num1, num2) == GT
    }

    /// Checks if the first I16 number is greater than or equal to the second
    public fun gte(num1: I16, num2: I16): bool {
        cmp(num1, num2) >= EQ
    }

    /// Checks if the first I16 number is less than the second
    public fun lt(num1: I16, num2: I16): bool {
        cmp(num1, num2) == LT
    }

    /// Checks if the first I16 number is less than or equal to the second
    public fun lte(num1: I16, num2: I16): bool {
        cmp(num1, num2) <= EQ
    }

    #[deprecated]
    /// Performs bitwise OR on two I16 numbers
    public fun or(num1: I16, num2: I16): I16 {
        I16 { bits: (num1.bits | num2.bits) }
    }

    #[deprecated]
    /// Performs bitwise AND on two I16 numbers
    public fun and(num1: I16, num2: I16): I16 {
        I16 { bits: (num1.bits & num2.bits) }
    }

    #[deprecated]
    public fun from_u16(v: u16): I16 {
        pack(v)
    }

    #[deprecated]
    // Converts an I16 to u16
    public fun as_u16(v: I16): u16 {
        unpack(v)
    }

    /// Two's complement in order to dervie negative representation of bits
    /// It is overflow-proof because we hardcode 2's complement of 0 to be 0
    /// Which is fine for our specific use case
    fun twos_complement(v: u16): u16 {
        if (v == 0) 0
        else (v ^ MASK_U16) + 1
    }
}
