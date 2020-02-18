@static if VERSION < v"1.3"
    using BinaryProvider # requires BinaryProvider 0.3.0 or later

    # Parse some basic command-line arguments
    const verbose = "--verbose" in ARGS
    const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
    products = [
        LibraryProduct(prefix, "libsodium", :libsodium),
    ]

    # Download binaries from hosted location
    bin_prefix = "https://github.com/JuliaBinaryWrappers/libsodium_jll.jl/releases/download/libsodium-v1.0.18+0"

    # Listing of files generated by BinaryBuilder:
    download_info = Dict(
        Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libsodium.v1.0.18.aarch64-linux-gnu.tar.gz", "859e6768252d94c9930510696cd7f9a4d5904e8e662d8587b3a3c360ce3a5fee"),
        Linux(:aarch64, libc=:musl) => ("$bin_prefix/libsodium.v1.0.18.aarch64-linux-musl.tar.gz", "5405244a95cdcca864b6b408f9e375f5bff5268b0f2c318572dbd9028f4e066f"),
        Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libsodium.v1.0.18.armv7l-linux-gnueabihf.tar.gz", "3a5050bebe74367781ba12def03541d1ad585dcb3d0da2705c309fe4092259e2"),
        Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libsodium.v1.0.18.armv7l-linux-musleabihf.tar.gz", "464e7d7e7a43e89ea45985f7b6544ba8a222d0423ce693eac9435152d9852b19"),
        Linux(:i686, libc=:glibc) => ("$bin_prefix/libsodium.v1.0.18.i686-linux-gnu.tar.gz", "0bef43df5e21db8de5b8c2ddc0cea1b257b6e64448aaec2ef09604d09e7ac1ec"),
        Linux(:i686, libc=:musl) => ("$bin_prefix/libsodium.v1.0.18.i686-linux-musl.tar.gz", "07e3c1ca970549af7af154116fd803c06e418d2f6647cd9365e7a801a44db8e2"),
        Windows(:i686) => ("$bin_prefix/libsodium.v1.0.18.i686-w64-mingw32.tar.gz", "3ee16d94abc27ffdc3f1a36128fbfacd66643e11d8290b6c6a1a66e9dba18d0f"),
        Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libsodium.v1.0.18.powerpc64le-linux-gnu.tar.gz", "95a465af36d8a0e30e55b0fa11abfebadea777b05fd7f6ce716065db63d7a4c7"),
        MacOS(:x86_64) => ("$bin_prefix/libsodium.v1.0.18.x86_64-apple-darwin14.tar.gz", "60abfca32682309d7d9f8fc64ae359c2a0a5972f3657ce4523a48720b95cf428"),
        Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libsodium.v1.0.18.x86_64-linux-gnu.tar.gz", "0c854fff7a4cc5f5c9657b46d769f2721f2aba0ca9c4df2a854ae4ab608b961f"),
        Linux(:x86_64, libc=:musl) => ("$bin_prefix/libsodium.v1.0.18.x86_64-linux-musl.tar.gz", "4a047e7538a4e8b4b833249f3332417c1c9eaa5f716b11c692965c79f5ea6266"),
        FreeBSD(:x86_64) => ("$bin_prefix/libsodium.v1.0.18.x86_64-unknown-freebsd11.1.tar.gz", "f592625bd8ad3a1592e6a19082bbbd8db185c140f8998577626750b52563d8b7"),
        Windows(:x86_64) => ("$bin_prefix/libsodium.v1.0.18.x86_64-w64-mingw32.tar.gz", "eee65837b7f9853148975e736a544ca038e4bc3343a356ba688c6325b153b1b6"),
    )

    # Install unsatisfied or updated dependencies:
    unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
    dl_info = choose_download(download_info, platform_key_abi())
    if dl_info === nothing && unsatisfied
        # If we don't have a compatible .tar.gz to download, complain.
        # Alternatively, you could attempt to install from a separate provider,
        # build from source or something even more ambitious here.
        error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
    end

    # If we have a download, and we are unsatisfied (or the version we're
    # trying to install is not itself installed) then load it up!
    if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
        # Download and install binaries
        install(dl_info...; prefix=prefix, force=true, verbose=verbose)
    end

    # Write out a deps.jl file that will contain mappings for our products
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
end
