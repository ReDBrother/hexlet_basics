defmodule HexletBasicsWeb.Language.ModuleView do
  use HexletBasicsWeb, :view

  def locales_switch_map, do: %{"ru" => "en", "en" => "ru"}
end

