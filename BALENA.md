# Hello, balena

This document contains information about the current automation and my plans for improvements.
For my perspectives on this work as I'm doing it, see the commit log.

## About This Library

SodiumSeal is a very small package.
It provides wrappers for just a couple of [libsodium](https://download.libsodium.org/doc) functions, namely those that deal with [sealed boxes](https://download.libsodium.org/doc/public-key_cryptography/sealed_boxes).
It was created to facilitate use of the new [GitHub Actions Secrets API](https://developer.github.com/v3/actions/secrets).

## What's Already Done

Thanks to existing efforts in the Julia ecosystem, setting up automation for libraries is quite easy.
This package was initalized with [PkgTemplates](https://github.com/invenia/PkgTemplates.jl), a package I wrote while working for [Invenia](https://invenia.ca) that creates new packages with best practices already set up.
These include automated testing, documentation, changelog and release automation, and dependency tracking.

### Automated Testing

Tests are run on [Travis CI](https://travis-ci.com), whose configuration is produced by PkgTemplates.
These tests run on the LTS, latest, and nightly release of Julia, on Linux, MacOS, and Windows.
In addition to the usual x64 architecture, x86 and ARM64 are also used when possible.

### Documentation

Documentation is produced with [Documenter](https://github.com/JuliaDocs/Documenter.jl).
This is set up automatically by PkgTemplates.
It reads docstrings in the source code and produces some nice HTML pages.
On pushes to the master branch, it also deploys that documentation to [GitHub Pages](https://pages.github.com).`

### GitHub Releases + Changelogs

Git tags and GitHub releases are not required by Julia, but they're a good practice nonetheless.
Thanks to a tool I built called [TagBot](https://github.com/JuliaRegistries/TagBot), you can have GitHub releases be created whenever you register new versions of your package.
As an added bonus, TagBot also generates a changelog for you from whatever issues and pull requests were closed since the previous release.
TagBot is installed by default with PkgTemplates.

### Dependency Tracking

Compatibility constraints for your dependencies can be automatically managed by [CompatHelper](https://github.com/bcbi/CompatHelper.jl), and this is set up by default with PkgTemplates.
Whenever new versions of dependencies that are not already allowed by our constraints are released, CompatHelper will open a pull request for you to review, test, and merge.
Because of our existing CI pipeline, we can merge those PRs with confidence that they don't break anything, provided that we adequately test the use of those dependencies.

### Binary Dependencies

As I mentioned, SodiumSeal depends on libsodium.
But what if my users don't have that library installed?
Thankfully, Julia has [BinaryBuilder](https://binarybuilder.org), an awesome system for bundling binary dependencies with your packages that supports a huge number of platforms.
There's a bit of extra work to make this function seamlessly on all versions of Julia, but as a result, any Julia developer can use this package without worrying about having system requirements installed.

## What To Improve?

PkgTemplates has been developed to fulfill the needs of the average Julia package.
If it does its job, there should be nothing left to do.
But of course, every project has its own quirks.
So here's what I plan to do:

### Interop Safety Checks

Most of this package's complications come from the fact that we're wrapping a C library, which brings in a lot of unsafeness.
If you fail to use `ccall` (the function for calling C functions) correctly, you'll get a segfault without much context to help you debug.
Therefore, I have an idea to write some code that analyzes the uses of `ccall` in this package and checks them against the actual libsodium API.
By doing so, we can hopefully add some safety that the Julia type system can't provide.

### Code Formatting

Code formatting in Julia is still fairly immature, but a few tools such as [JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl) are being developed.
Style guides are an important part of large-scale software efforts, so it would be a good idea 

### Code Coverage

There are some cases in which I think code coverage is an ineffective metric, but it never hurts to add when it's not too difficult.
Code coverage through [Codecov](https://codecov.io) or [Coveralls](https://coveralls.io) is supported by PkgTemplates, but I'll just need to add a few lines manually since i didn't do it at package generation time.
Additionally, it may be useful to add a code coverage threshold to ensure that new functionality is being tested.

### Static Compilation

Julia is a JIT-compiled language, and its compilation can sometimes be slow.
Thankfully, there exists [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl), a tool for creating a custom system image with your packages compiled in.
However, this tooling is still pretty young, and it doesn't always work.
It would be nice to automate the building a system image to make sure that it works.
Sometimes, failures can be remedied by fixing issues with your code.

### More Test Platforms

BinaryBuilder supports many platforms that Travis CI does not.
There are a couple of other services that can run on these other platforms, and it would be good to set those up to make sure that all those platforms are usable.
