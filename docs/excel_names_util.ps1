##
## excel_names_util.ps1
##
## エクスポートモード:Excelファイルから名前定義をテキストファイルに出力します。
## インポートモード:名前定義のテキストファイルを読み、Excelファイルに名前定義します。既に存在する名前定義は上書きします。
##
param(
  [Parameter(Mandatory=$false)]
  [ValidateSet("Export", "Import")]
  [string]$Mode,

  [Parameter(Mandatory=$false)]
  [string]$InputPath,

  [Parameter(Mandatory=$false)]
  [string]$OutputPath,

  [switch]$Help
)
function Show-Help {
  "機能"
  "エクスポートモード:Excelファイルから名前定義をテキストファイルに出力します。"
  "インポートモード:名前定義のテキストファイルを読み、Excelファイルに名前定義します。既に存在する名前定義は上書きします。"
  ""
  "使用方法: .\excel_names_util.ps1 -Mode <Export|Import> -InputPath <path> -OutputPath <path>"
  ""
  "例:"
  "エクスポートの場合: .\excel_names_util.ps1 -Mode Export -InputPath '.\excel.xlsx' -OutputPath '.\names.txt'"
  "インポートの場合: .\excel_names_util.ps1 -Mode Import -InputPath '.\names.txt' -OutputPath '.\other_exists_excel.xlsx'"
  "ヘルプを表示: .\excel_names_util.ps1 -Help"
  ""
  "「.\excel_names_util.ps1 : このシステムではスクリプトの実行が無効になっているため」のエラーが表示される場合は、"
  "PowerShell -ExecutionPolicy RemoteSigned -File .\excel_names_util.ps1 の様に実行時のポリシーを変更して実行してください。"
  exit
}
if ($Help) {
    Show-Help
}

function ConvertTo-AbsolutePath {
  param(
    [string]$Path
  )

  ## 相対パスを絶対パスに変換（ファイルの存在チェックなし）
  return [System.IO.Path]::GetFullPath($Path)
}

function Export-NameDefinitions {
  param(
    [string]$ExcelFilePath,
    [string]$TextFilePath
  )
  ## ワークブックを開く
  $workbook = $excel.Workbooks.Open($ExcelFilePath)

  ## 名前定義のコレクションを取得
  $names = $workbook.Names

  ## 名前定義をAppendでファイルに書き込んでいくので、いったんエクスポートファイルを空にする
  Set-Content -Path $TextFilePath -Value $null -NoNewline

  ## 名前定義をファイルにエクスポート
  $names | ForEach-Object {
    $name = $_.Name
    $refersTo = $_.RefersTo
    ## 名前と定義内容はタブ区切り
    "$name`t$refersTo" | Out-File -FilePath $TextFilePath -Append -Encoding UTF8
  }

  ## ワークブックを閉じる(false:保存しない)
  $workbook.Close($false)
}

function Import-NameDefinitions {
  param(
    [string]$TextFilePath,
    [string]$ExcelFilePath
  )
  ## ワークブックを開く
  $workbook = $excel.Workbooks.Open($ExcelFilePath)

  ## 名前定義ファイルを読み、ワークブックに追加
  ## 既に同じ名前定義が存在していたら上書き
  $nameDefinitions = Get-Content -Path $TextFilePath
  foreach ($definition in $nameDefinitions) {
    ## 名前と定義内容はタブ区切り
    $parts = $definition -split "`t"
    $name = $parts[0]
    $refersTo = $parts[1]
    try{
      $workbook.Names.Add($name, $refersTo)
    } catch{
      ## ユーザが定義していない名前定義(_xlfnや_xlpm)をAddしようとすると
      ## 例外が発生するのでキャッチするが、次の名前定義の追加に進ようにしている。
      Write-Host $name "の名前定義の追加でエラーが発生しました: $_"
      Write-Host "次の名前定義の追加を継続します。"
    }
  }
  ## ワークブックを閉じる(true:上書き保存)
  $workbook.Close($true)
}

## Excelアプリケーションオブジェクトを作成
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

try {
  ## 入力パスと出力パスを絶対パスに変換
  $InputPath = ConvertTo-AbsolutePath -Path $InputPath
  $OutputPath = ConvertTo-AbsolutePath -Path $OutputPath

  switch ($Mode) {
    "Export" {
      Export-NameDefinitions -ExcelFilePath $InputPath -TextFilePath $OutputPath
    }
    "Import" {
      Import-NameDefinitions -TextFilePath $InputPath -ExcelFilePath $OutputPath
    }
  }
} catch {
  Write-Host "エラーが発生しました: $_"
} finally {
  ## オブジェクトを解放
  $excel.Quit()
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
  Remove-Variable excel
}

Write-Host "操作が完了しました。"
