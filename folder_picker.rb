class FolderPicker
  def self.browse
    # Sadece Windows'ta çalışacak
    unless RUBY_PLATFORM =~ /mswin|mingw|cygwin/
      return nil
    end

    # PowerShell command to open FolderBrowserDialog
    # Tek satırlık komut
    ps_cmd = "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.FolderBrowserDialog; $dialog.Description = 'Select a folder'; $dialog.ShowNewFolderButton = $true; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $dialog.SelectedPath }"

    begin
      result = `powershell -NoProfile -Sta -Command "#{ps_cmd}"`
      path = result.strip
      path.empty? ? nil : path
    rescue => e
      nil
    end
  end
end
