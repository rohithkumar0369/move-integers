# Move Integer Modules

⚠️ **WARNING: These Move modules have not been audited. Use with caution in production environments. The authors are not responsible for any potential issues or vulnerabilities.** ⚠️

## Overview

This repository contains a collection of Move modules implementing various integer sizes. These modules are designed to provide more flexibility in integer operations within Move smart contracts.

## Modules

The following modules are included:

- `i8.move`: 8-bit signed integer operations
- `i16.move`: 16-bit signed integer operations
- `i32.move`: 32-bit signed integer operations
- `i64.move`: 64-bit signed integer operations
- `i128.move`: 128-bit signed integer operations
- `i256.move`: 256-bit signed integer operations

Each module provides basic arithmetic operations and comparisons for its respective integer size.

## Usage

To use these modules in your Move project, you can import them as follows:

```rust
use 0xfff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i64;
use 0xfff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i128;
// ... and so on for other modules
```

Replace `<your_address>` with the appropriate address where you've deployed these modules.

## Testing

Unit tests for each module can be found in the module. To run the tests, use the Move CLI:

```
aptos move test
```

## Contributing

Contributions to improve these modules are welcome. Please ensure you add appropriate tests for any new functionality.

## Acknowledgements

This project drew inspiration from the Integer Mate repository by Cetus Protocol. Their work has been a valuable contribution to the Move ecosystem.

## License

This project is licensed under the MIT License.

## Contact

For questions or concerns, you can reach out to the maintainer on Twitter: [@0xanto](https://twitter.com/0xanto)

Remember to use these modules responsibly and consider a thorough audit before deploying them in any production environment.