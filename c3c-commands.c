/*
  compile <file1> [<file2> ...]                       Compile files without a project into an executable.
  init <project name>                                 Initialize a new project structure.
  init-lib <library name>                             Initialize a new library structure.
  build [<target>]                                    Build the target in the current project.
  benchmark                                           Run the benchmarks in the current project.
  test                                                Run the unit tests in the current project.
  clean                                               Clean all build files.
  run [<target>] [-- [<arg1> ...]]                    Run (and build if needed) the target in the current project.
  dist [<target>]                                     Clean and build a target for distribution.
  directives [<target>]                               Generate documentation for the target.
  bench [<target>]                                    Benchmark a target.
  clean-run [<target>] [-- [<arg1> ...]]              Clean, then run the target.
  compile-run <file1> [<file2> ...] [-- [<arg1> ...]] Compile files then immediately run the result.
  compile-only <file1> [<file2> ...]                  Compile files but do not perform linking.
  compile-benchmark <file1> [<file2> ...]             Compile files into an executable and run benchmarks.
  compile-test <file1> [<file2> ...]                  Compile files into an executable and run unit tests.
  static-lib <file1> [<file2> ...]                    Compile files without a project into a static library.
  dynamic-lib <file1> [<file2> ...]                   Compile files without a project into a dynamic library.
  headers <file1> [<file2> ...]                       Analyse files and generate C headers for public methods.
  vendor-fetch <library> ...                          Fetches one or more libraries from the vendor collection.
  project <subcommand> ...                            Manipulate or view project files.

Options:
  --stdlib <dir>             - Use this directory as the C3 standard library path.
  --no-entry                 - Do not generate (or require) a main function.
  --libdir <dir>             - Add this directory to the C3 library search paths.
  --lib <name>               - Add this library to the compilation.
  --path <dir>               - Use this as the base directory for the current command.
  --template <template>      - Select template for 'init': "exe", "static-lib", "dynamic-lib" or a path.
  --about                    - Prints a short description of C3.
  --symtab <value>           - Sets the preferred symtab size.
  --max-mem <value>          - Sets the preferred max memory size.
  --run-once                 - After running the output file, delete it immediately.
  -V --version               - Print version information.
  -q --quiet                 - Silence unnecessary output.
  -v -vv -vvv                - Verbose output, -v for default, -vv and -vvv gives more information.
  -E                         - Lex only.
  -P                         - Only parse and output the AST as JSON.
  -C                         - Only lex, parse and check.
  -                          - Read code from standard in.
  -o <file>                  - Write output to <file>.
  -O0                        - Safe, no optimizations, emit debug info.
  -O1                        - Safe, high optimization, emit debug info.
  -O2                        - Unsafe, high optimization, emit debug info.
  -O3                        - Unsafe, high optimization, single module, emit debug info.
  -O4                        - Unsafe, highest optimization, relaxed maths, single module, emit debug info, no panic messages.
  -O5                        - Unsafe, highest optimization, fast maths, single module, emit debug info, no panic messages, no backtrace.
  -Os                        - Unsafe, high optimization, small code, single module, no debug info, no panic messages.
  -Oz                        - Unsafe, high optimization, tiny code, single module, no debug info, no panic messages, no backtrace.
  -D <name>                  - Add feature flag <name>.
  -U <name>                  - Remove feature flag <name>.
  --trust=<option>           - Trust level: none (default), include ($include allowed), full ($exec / exec allowed).
  --output-dir <dir>         - Override general output directory.
  --build-dir <dir>          - Override build output directory.
  --obj-out <dir>            - Override object file output directory.
  --script-dir <dir>         - Override the base directory for $exec.
  --llvm-out <dir>           - Override llvm output directory for '--emit-llvm'.
  --emit-llvm                - Emit LLVM IR as a .ll file per module.
  --asm-out <dir>            - Override asm output directory for '--emit-asm'.
  --emit-asm                 - Emit asm as a .s file per module.
  --obj                      - Emit object files. (Enabled by default)
  --no-obj                   - Do not output object files, this is only valid for `compile-only`.
  --no-headers               - Do not generate C headers when building a library.
  --target <target>          - Compile for a particular architecture + OS target.
  --threads <number>         - Set the number of threads to use for compilation.
  --safe=<yes|no>            - Turn safety (contracts, runtime bounds checking, null pointer checks etc) on or off.
  --panic-msg=<yes|no>       - Turn panic message output on or off.
  --optlevel=<option>        - Code optimization level: none, less, more, max.
  --optsize=<option>         - Code size optimization: none, small, tiny.
  --single-module=<yes|no>   - Compile all modules together, enables more inlining.
  --show-backtrace=<yes|no>  - Show detailed backtrace on segfaults.

  -g                         - Emit debug info.
  -g0                        - Emit no debug info.

  -l <library>               - Link with the library provided.
  -L <library dir>           - Append the directory to the linker search paths.
  -z <argument>              - Send the <argument> as a parameter to the linker.
  --cc <path>                - Set C compiler (for C files in projects and use as system linker).
  --linker=<option> [<path>] - Linker: builtin, cc, custom (default is 'cc'), 'custom' requires a path.

  --use-stdlib=<yes|no>      - Include the standard library (default: yes).
  --link-libc=<yes|no>       - Link libc other default libraries (default: yes).
  --emit-stdlib=<yes|no>     - Output files for the standard library. (default: yes)
  --panicfn <name>           - Override the panic function name.
  --testfn <name>            - Override the test runner function name.
  --benchfn <name>           - Override the benchmark runner function name.

  --reloc=<option>           - Relocation model: none, pic, PIC, pie, PIE.
  --x86cpu=<option>          - Set general level of x64 cpu: baseline, ssse3, sse4, avx1, avx2-v1, avx2-v2 (Skylake/Zen1+), avx512 (Icelake/Zen4+), native.
  --x86vec=<option>          - Set max type of vector use: none, mmx, sse, avx, avx512, default.
  --riscvfloat=<option>      - Set type of RISC-V float support: none, float, double
  --memory-env=<option>      - Set the memory environment: normal, small, tiny, none.
  --strip-unused=<yes|no>    - Strip unused code and globals from the output. (default: yes)
  --fp-math=<option>         - FP math behaviour: strict, relaxed, fast.
  --win64-simd=<option>      - Win64 SIMD ABI: array, full.

  --print-linking            - Print linker arguments.

  --benchmarking             - Run built-in benchmarks.
  --testing                  - Run built-in tests.

  --list-attributes          - List all attributes.
  --list-builtins            - List all builtins.
  --list-keywords            - List all keywords.
  --list-operators           - List all operators.
  --list-precedence          - List operator precedence order.
  --list-project-properties  - List all available keys used in project.json files.
  --list-manifest-properties - List all available keys used in manifest.json files.
  --list-targets             - List all architectures the compiler supports.
  --list-type-properties     - List all type properties.

  --print-output             - Print the object files created to stdout.
  --print-input              - Print inputted C3 files to stdout.

  --winsdk <dir>             - Set the directory for Windows system library files for cross compilation.
  --wincrt=<option>          - Windows CRT linking: none, static-debug, static, dynamic-debug (default if debug info enabled), dynamic (default).
  --windef <file>            - Use Windows 'def' file for function exports instead of 'dllexport'.

  --macossdk <dir>           - Set the directory for the MacOS SDK for cross compilation.
  --macos-min-version <ver>  - Set the minimum MacOS version to compile for.
  --macos-sdk-version <ver>  - Set the MacOS SDK compiled for.

  --linux-crt <dir>          - Set the directory to use for finding crt1.o and related files.
  --linux-crtbegin <dir>     - Set the directory to use for finding crtbegin.o and related files.

  --vector-conv=<option>     - Set vector conversion behaviour: default, old.
  --sanitize=<option>        - Enable sanitizer: address, memory, thread.
*/