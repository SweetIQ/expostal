defmodule Mix.Tasks.Compile.Libpostal do
  def run(_) do
    if match? {:win32, _}, :os.type do
      # libpostal does not support Windows unfortunately.
      IO.warn("Windows is not supported.")
      exit(1)
    else
      {result, _error_code} = System.cmd("make", ["priv/parser.so"], stderr_to_stdout: true)
      IO.binwrite result
      {result, _error_code} = System.cmd("make", ["priv/expand.so"], stderr_to_stdout: true)
      IO.binwrite result
    end
    :ok
  end
end

defmodule Expostal.Mixfile do
  use Mix.Project

  def project do
    [app: :expostal,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:libpostal, :elixir, :app],
     docs: [main: "readme",
       extras: ["README.md"]],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
