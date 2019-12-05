defmodule Arrow.RepoTest do
  use ExUnit.Case, async: false

  defmodule FakeAwsRds do
    def generate_db_auth_token(_, _, _, _) do
      "iam_token"
    end
  end

  @default_config [
    pool_size: 8,
    database: "test"
  ]

  describe "init/2" do
    test "fills in :pool_size based on ENV" do
      System.put_env("DATABASE_POOL_SIZE", "9")
      on_exit(fn -> System.delete_env("DATABASE_POOL_SIZE") end)

      config = Keyword.put(@default_config, :pool_size, 5)
      assert {:ok, config} = Arrow.Repo.init(:supervisor, config)

      assert Keyword.get(config, :pool_size) == 9
    end

    test "leaves existing :pool_size in there" do
      config = Keyword.put(@default_config, :pool_size, 5)
      assert {:ok, config} = Arrow.Repo.init(:supervisor, config)

      assert Keyword.get(config, :pool_size) == 5
    end

    test "provides default :pool_size" do
      config = Keyword.delete(@default_config, :pool_size)
      assert {:ok, config} = Arrow.Repo.init(:supervisor, config)

      assert Keyword.get(config, :pool_size) == 10
    end

    test "keeps DB credentials if provided" do
      config = Keyword.put(@default_config, :username, "test_user")
      assert {:ok, config} = Arrow.Repo.init(:supervisor, config)
      assert Keyword.get(config, :username) == "test_user"
    end

    test "raises an exception if empty credentials and no ENV vars" do
      config = Keyword.delete(@default_config, :database)

      assert_raise(ArgumentError, fn ->
        Arrow.Repo.init(:supervisor, config)
      end)
    end

    test "gets password token for RDS IAM auth" do
      previous_rds_mod = Application.get_env(:arrow, :aws_rds_mod)
      Application.put_env(:arrow, :aws_rds_mod, FakeAwsRds)
      System.put_env("DATABASE_USER", "db_user")
      System.put_env("DATABASE_HOST", "db_host")
      System.put_env("DATABASE_NAME", "db_name")
      System.put_env("DATABASE_PORT", "9999")

      on_exit(fn ->
        Application.put_env(:arrow, :aws_rds_mod, previous_rds_mod)
        System.delete_env("DATABASE_USER")
        System.delete_env("DATABASE_HOST")
        System.delete_env("DATABASE_NAME")
        System.delete_env("DATABASE_PORT")
      end)

      config = Keyword.delete(@default_config, :database)

      assert {:ok, config} = Arrow.Repo.init(:supervisor, config)
      assert Keyword.get(config, :password) == "iam_token"
    end
  end
end
