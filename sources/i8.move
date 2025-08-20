module move_int::i8 {
    const OVERFLOW: u64 = 0;
    const DIVISION_BY_ZERO: u64 = 1;

    /// min number that a I8 could represent = (1 followed by 7 0s) = 1 << 7
    const BITS_MIN_I8: u8 = 1 << 7;

    /// max number that a I8 could represent = (0 followed by 7 1s) = (1 << 7) - 1
    const BITS_MAX_I8: u8 = 0x7f;

    /// 8 1s
    const MASK_U8: u8 = 0xff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I8 has copy, drop, store {
        bits: u8
    }

    /// Creates an I8 from a u8, asserting that it's not greater than the maximum positive value
    public fun from(v: u8): I8 {
        assert!(v <= BITS_MAX_I8, OVERFLOW);
        I8 { bits: v }
    }

    /// Creates a negative I8 from a u8, asserting that it's not greater than the minimum negative value
    public fun neg_from(v: u8): I8 {
        assert!(v <= BITS_MIN_I8, OVERFLOW);
        I8 { bits: twos_complement(v) }
    }

    /// Performs wrapping addition on two I8 numbers
    public fun wrapping_add(num1: I8, num2: I8): I8 {
        I8 { bits: (((num1.bits as u16) + (num2.bits as u16)) & (MASK_U8 as u16) as u8) }
    }

    /// Performs checked addition on two I8 numbers, abort on overflow
    public fun add(num1: I8, num2: I8): I8 {
        let sum = wrapping_add(num1, num2);
        // overflow only if: (1) postive + postive = negative, OR (2) negative + negative = positive
        let is_num1_neg = is_neg(num1);
        let is_num2_neg = is_neg(num2);
        let is_sum_neg = is_neg(sum);
        let overflow = (is_num1_neg && is_num2_neg && !is_sum_neg) || (!is_num1_neg && !is_num2_neg && is_sum_neg);
        assert!(!overflow, OVERFLOW);
        sum
    }

    /// Performs wrapping subtraction on two I8 numbers
    public fun wrapping_sub(num1: I8, num2: I8): I8 {
        wrapping_add(num1, I8 { bits: twos_complement(num2.bits) })
    }

    /// Performs checked subtraction on two I8 numbers, asserting on overflow
    public fun sub(num1: I8, num2: I8): I8 {
        add(num1, I8 { bits: twos_complement(num2.bits) })
    }

    /// Performs multiplication on two I8 numbers
    public fun mul(num1: I8, num2: I8): I8 {
        let product = (abs_u8(num1) as u16) * (abs_u8(num2) as u16);
        if (sign(num1) != sign(num2)) {
            assert!(product <= (BITS_MIN_I8 as u16), OVERFLOW);
            neg_from((product as u8))
        } else {
            assert!(product <= (BITS_MAX_I8 as u16), OVERFLOW);
            from((product as u8))
        }
    }

    /// Performs division on two I8 numbers
    /// Note that we mimic the behavior of solidity int division that it rounds towards 0 rather than rounds down
    /// - rounds towards 0: (-4) / 3 = -(4 / 3) = -1 (remainder = -1)
    /// - rounds down: (-4) / 3 = -2 (remainder = 2)
    public fun div(num1: I8, num2: I8): I8 {
        assert!(!is_zero(num2), DIVISION_BY_ZERO);
        let result = abs_u8(num1) / abs_u8(num2);
        if (sign(num1) != sign(num2)) neg_from(result)
        else from(result)
    }

    /// Performs modulo on two I8 numbers
    /// a mod b = a - b * (a / b)
    public fun mod(num1: I8, num2: I8): I8 {
        let quotient = div(num1, num2);
        sub(num1, mul(num2, quotient))
    }

    /// Returns the absolute value of an I8 number
    public fun abs(v: I8): I8 {
        let bits = if (sign(v) == 0) { v.bits }
        else {
            assert!(v.bits > BITS_MIN_I8, OVERFLOW);
            twos_complement(v.bits)
        };
        I8 { bits }
    }

    /// Returns the absolute value of an I8 number as a u8
    public fun abs_u8(v: I8): u8 {
        if (sign(v) == 0) v.bits
        else twos_complement(v.bits)
    }

    /// Returns the minimum of two I8 numbers
    public fun min(a: I8, b: I8): I8 {
        if (lt(a, b)) a else b
    }

    /// Returns the maximum of two I8 numbers
    public fun max(a: I8, b: I8): I8 {
        if (gt(a, b)) a else b
    }

    /// Raises an I8 number to a u8 power
    public fun pow(base: I8, exponent: u8): I8 {
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

    /// Creates an I8 from a u8 without any checks
    public fun pack(v: u8): I8 {
        I8 { bits: v }
    }

    /// Get internal bits of I8
    public fun unpack(v: I8): u8 {
        v.bits
    }

    /// Returns the sign of an I8 number (0 for positive, 1 for negative)
    public fun sign(v: I8): u8 {
        ((v.bits >> 7) as u8)
    }

    /// Creates and returns an I8 representing zero
    public fun zero(): I8 {
        I8 { bits: 0 }
    }

    /// Checks if an I8 number is zero
    public fun is_zero(v: I8): bool {
        v.bits == 0
    }

    /// Checks if an I8 number is negative
    public fun is_neg(v: I8): bool {
        sign(v) == 1
    }

    /// Compares two I8 numbers, returning LT, EQ, or GT
    public fun cmp(num1: I8, num2: I8): u8 {
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

    /// Checks if two I8 numbers are equal
    public fun eq(num1: I8, num2: I8): bool {
        cmp(num1, num2) == EQ
    }

    /// Checks if the first I8 number is greater than the second
    public fun gt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == GT
    }

    /// Checks if the first I8 number is greater than or equal to the second
    public fun gte(num1: I8, num2: I8): bool {
        cmp(num1, num2) >= EQ
    }

    /// Checks if the first I8 number is less than the second
    public fun lt(num1: I8, num2: I8): bool {
        cmp(num1, num2) == LT
    }

    /// Checks if the first I8 number is less than or equal to the second
    public fun lte(num1: I8, num2: I8): bool {
        cmp(num1, num2) <= EQ
    }

    #[deprecated]
    /// Performs bitwise OR on two I8 numbers
    public fun or(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits | num2.bits) }
    }

    #[deprecated]
    /// Performs bitwise AND on two I8 numbers
    public fun and(num1: I8, num2: I8): I8 {
        I8 { bits: (num1.bits & num2.bits) }
    }

    #[deprecated]
    public fun from_u8(v: u8): I8 {
        pack(v)
    }

    #[deprecated]
    // Converts an I8 to u8
    public fun as_u8(v: I8): u8 {
        unpack(v)
    }

    /// Two's complement in order to dervie negative representation of bits
    /// It is overflow-proof because we hardcode 2's complement of 0 to be 0
    /// Which is fine for our specific use case
    fun twos_complement(v: u8): u8 {
        if (v == 0) 0
        else (v ^ MASK_U8) + 1
    }
}

