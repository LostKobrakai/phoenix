defmodule Mix.Tasks.Phx.New.Web do
  @moduledoc """
  Creates a new Phoenix web project within an umbrella application.

  It expects the name of the otp app as the first argument and
  for the command to be run inside your umbrella application's
  apps directory:

      $ cd my_umbrella/apps
      $ mix phx.new.web APP [--module MODULE] [--app APP]

  This task is inteded to create a bare Phoenix project without
  database integration, which interfaces with your greater
  umbrella application(s).

  ## Examples

      mix phx.new.web hello_web

  Is equivalent to:

      mix phx.new.web hello_web --module Hello.Web

  Supports the same options as the `phx.new` task.
  See `Mix.Tasks.Phx.New` for details.
  """
  use Mix.Task

  def run([path | _] = args) do
    unless Phx.New.Generator.in_umbrella?(path) do
      Mix.raise "The web task can only be run within an umbrella's apps directory"
    end

    Mix.Tasks.Phx.New.run(args, Phx.New.Web)
  end
end
