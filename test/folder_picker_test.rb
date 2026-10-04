require 'minitest/autorun'
require 'minitest/mock'
require_relative '../folder_picker'

class FolderPickerTest < Minitest::Test
  def test_returns_nil_on_non_windows
    # Mocking RUBY_PLATFORM check if possible, or just mock the method.
    # We can use stubbing to test the behavior.
    
    FolderPicker.stub :`, "" do
      # When the shell command returns empty string, it should return nil
      assert_nil FolderPicker.browse
    end
  end

  def test_returns_path_when_selected
    expected_path = "C:\\Users\\Test\\Documents"
    
    FolderPicker.stub :`, expected_path + "\n" do
      # When the shell command returns a path, it should return that path
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        assert_equal expected_path, FolderPicker.browse
      else
        assert_nil FolderPicker.browse # On non-windows it always returns nil
      end
    end
  end
end
