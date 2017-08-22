class AzureCliAT20 < Formula
  include Language::Python::Virtualenv

  desc "Microsoft Azure CLI 2.0"
  homepage "https://docs.microsoft.com/en-us/cli/azure/overview"
  url "https://azurecliprod.blob.core.windows.net/releases/azure-cli_packaged_2.0.14.tar.gz"
  sha256 "b811562bff46685c1850704aabde794c66468457e20fbf10258784f9891a2f5f"
  head "https://github.com/Azure/azure-cli.git"

  depends_on :python if MacOS.version <= :snow_leopard

  def install
    virtualenv_create(libexec)
    bin_dir = libexec/"bin"

    components = [
      buildpath/"src/azure-cli",
      buildpath/"src/azure-cli-core",
      buildpath/"src/azure-cli-nspkg",
      buildpath/"src/azure-cli-command_modules-nspkg",
    ] + Pathname.glob("src/command_modules/azure-cli-*/")

    # Create wheel distribution of included components
    components.each do |c|
      c.cd { system bin_dir/"python", "setup.py", "bdist_wheel", "-d", buildpath/"dist" }
    end

    # Install CLI from wheel distributions
    system bin_dir/"pip", "install", "azure-cli", "-f", buildpath/"dist"

    # Generate executable
    (bin/"az").write <<-EOS.undent
      #!/usr/bin/env bash
      #{bin_dir}/python -m azure.cli "$@"
    EOS

    # Install bash completion
    bash_completion.install "az.completion" => "az"
  end

  test do
    version_output = shell_output("#{bin}/az --version")
    assert_match "azure-cli", version_output
  end
end
