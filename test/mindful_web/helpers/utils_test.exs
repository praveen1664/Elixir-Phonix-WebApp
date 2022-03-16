defmodule MindfulWeb.Helpers.UtilsTest do
  use MindfulWeb.ConnCase, async: true

  alias MindfulWeb.Helpers.Utils

  describe "slugified_name/1" do
    test "must raise error when argument is not a binary" do
      assert_raise FunctionClauseError, fn ->
        Utils.slugified_name(%{})
      end

      assert_raise FunctionClauseError, fn ->
        Utils.slugified_name(true)
      end

      assert_raise FunctionClauseError, fn ->
        Utils.slugified_name(nil)
      end
    end

    test "must return blank when given name is blank" do
      assert Utils.slugified_name("") == ""
    end

    test "must replace blank spaces with -" do
      name = "my name "
      result = Utils.slugified_name(name)

      assert result == "my-name"

      name = "my name    otherNAME"
      result = Utils.slugified_name(name)

      assert result == "my-name-othername"
    end

    test "must remove invalid chars" do
      name = "my name #"
      result = Utils.slugified_name(name)

      assert result == "my-name-"
    end

    test "must slugify weird names" do
      name = "1-my xpa c@"
      result = Utils.slugified_name(name)

      assert result == "1-my-xpa-c"

      name = "1-my xpa c @"
      result = Utils.slugified_name(name)

      assert result == "1-my-xpa-c-"
    end
  end

  describe "convert_to_keyword_list/1" do
    test "must return a keyword list when map has a string key" do
      map = %{"key" => "value", "key2" => "value2"}
      result = Utils.convert_to_keyword_list(map)

      assert result == [{"key", "value"}, {"key2", "value2"}]
    end

    test "must return a keyword list when map has an atom key" do
      map = %{key: "value", key2: "value2"}
      result = Utils.convert_to_keyword_list(map)

      assert result == [key: "value", key2: "value2"]
    end
  end

  describe "state_abbrs/0" do
    test "must return states abbrs sorted asc" do
      [first | tail] = Utils.state_abbrs()
      [last | _] = Enum.reverse(tail)

      assert first == "AK"
      assert last == "WY"
    end
  end

  describe "name_for_abbr/1" do
    test "must return a state name for a given valid abrr" do
      result = Utils.name_for_abbr("WI")
      assert result == "Wisconsin"

      result = Utils.name_for_abbr("VA")
      assert result == "Virginia"
    end

    test "must return nil for an invalid abbr" do
      result = Utils.name_for_abbr("IV")

      assert is_nil(result)
    end
  end
end
