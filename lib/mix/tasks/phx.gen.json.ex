defmodule Mix.Tasks.Phx.Gen.Json do
  @shortdoc "Generates controller, views, and context for a JSON resource"

  @moduledoc """
  Generates controller, views, and context for an JSON resource.

      mix phx.gen.json Accounts User users name:string age:integer

  The first argument is the context module followed by the schema module
  and its plural name (used as the schema table name).

  The context is an Elixir module that serves as an API boundary for
  the given resource. A context often holds many related resources.
  Therefore, if the context already exists, it will be augmented with
  functions for the given resource. Note a resource may also be split
  over distinct contexts (such as Accounts.User and Payments.User).

  The schema is responsible for mapping the database fields into an
  Elixir struct.

  Overall, this generator will add the following files to lib/your_app:

    * a context module in accounts/accounts.ex, serving as the API boundary
    * a schema in accounts/user.ex, with an `accounts_users` table
    * a view in web/views/user_view.ex
    * a controller in web/controllers/user_controller.ex

  A migration file for the repository and test files for the context and
  controller features will also be generated.

  ## Schema options

  By deault, the schema table name will be the plural name, namespaced by the
  context name. You can customize this value by providing the `--table`
  option to the generator.

  Read the documentation for `phx.gen.schema` for more information on
  attributes and supported options.
  """

  use Mix.Task

  alias Mix.Phoenix.Context
  alias Mix.Tasks.Phx.Gen

  def run(args) do
    if Mix.Project.umbrella? do
      Mix.raise "mix phx.gen.json can only be run inside an application directory"
    end

    {context, schema} = Gen.Context.build(args)
    binding = [context: context, schema: schema]
    paths = Mix.Phoenix.generator_paths()

    context
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  def copy_new_files(%Context{schema: schema} = context, paths, binding) do
    web_prefix = Mix.Phoenix.web_prefix()
    test_prefix = Mix.Phoenix.test_prefix()

    Mix.Phoenix.copy_from paths, "priv/templates/phx.gen.json", "", binding, [
      {:eex,     "controller.ex",          Path.join(web_prefix, "controllers/#{schema.singular}_controller.ex")},
      {:eex,     "view.ex",                Path.join(web_prefix, "views/#{schema.singular}_view.ex")},
      {:eex,     "controller_test.exs",    Path.join(test_prefix, "controllers/#{schema.singular}_controller_test.exs")},
      {:new_eex, "changeset_view.ex",      Path.join(web_prefix, "views/changeset_view.ex")},
      {:new_eex, "fallback_controller.ex", Path.join(web_prefix, "controllers/fallback_controller.ex")},
    ]

    Gen.Context.copy_new_files(context, paths, binding)
    context
  end

  def print_shell_instructions(%Context{schema: schema} = context) do
    Mix.shell.info """

    Add the resource to your api scope in lib/#{Mix.Phoenix.otp_app()}/web/router.ex:

        resources "/#{schema.plural}", #{inspect schema.alias}Controller, except: [:new, :edit]
    """
    Gen.Context.print_shell_instructions(context)
  end
end
