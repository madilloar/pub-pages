##
## excel_names_util.ps1
##
## �G�N�X�|�[�g���[�h:Excel�t�@�C�����疼�O��`���e�L�X�g�t�@�C���ɏo�͂��܂��B
## �C���|�[�g���[�h:���O��`�̃e�L�X�g�t�@�C����ǂ݁AExcel�t�@�C���ɖ��O��`���܂��B���ɑ��݂��閼�O��`�͏㏑�����܂��B
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
  "�@�\"
  "�G�N�X�|�[�g���[�h:Excel�t�@�C�����疼�O��`���e�L�X�g�t�@�C���ɏo�͂��܂��B"
  "�C���|�[�g���[�h:���O��`�̃e�L�X�g�t�@�C����ǂ݁AExcel�t�@�C���ɖ��O��`���܂��B���ɑ��݂��閼�O��`�͏㏑�����܂��B"
  ""
  "�g�p���@: .\excel_names_util.ps1 -Mode <Export|Import> -InputPath <path> -OutputPath <path>"
  ""
  "��:"
  "�G�N�X�|�[�g�̏ꍇ: .\excel_names_util.ps1 -Mode Export -InputPath '.\excel.xlsx' -OutputPath '.\names.txt'"
  "�C���|�[�g�̏ꍇ: .\excel_names_util.ps1 -Mode Import -InputPath '.\names.txt' -OutputPath '.\other_exists_excel.xlsx'"
  "�w���v��\��: .\excel_names_util.ps1 -Help"
  ""
  "�u.\excel_names_util.ps1 : ���̃V�X�e���ł̓X�N���v�g�̎��s�������ɂȂ��Ă��邽�߁v�̃G���[���\�������ꍇ�́A"
  "PowerShell -ExecutionPolicy RemoteSigned -File .\excel_names_util.ps1 �̗l�Ɏ��s���̃|���V�[��ύX���Ď��s���Ă��������B"
  exit
}
if ($Help) {
    Show-Help
}

function ConvertTo-AbsolutePath {
  param(
    [string]$Path
  )

  ## ���΃p�X���΃p�X�ɕϊ��i�t�@�C���̑��݃`�F�b�N�Ȃ��j
  return [System.IO.Path]::GetFullPath($Path)
}

function Export-NameDefinitions {
  param(
    [string]$ExcelFilePath,
    [string]$TextFilePath
  )
  ## ���[�N�u�b�N���J��
  $workbook = $excel.Workbooks.Open($ExcelFilePath)

  ## ���O��`�̃R���N�V�������擾
  $names = $workbook.Names

  ## ���O��`��Append�Ńt�@�C���ɏ�������ł����̂ŁA��������G�N�X�|�[�g�t�@�C������ɂ���
  Set-Content -Path $TextFilePath -Value $null -NoNewline

  ## ���O��`���t�@�C���ɃG�N�X�|�[�g
  $names | ForEach-Object {
    $name = $_.Name
    $refersTo = $_.RefersTo
    ## ���O�ƒ�`���e�̓^�u��؂�
    "$name`t$refersTo" | Out-File -FilePath $TextFilePath -Append -Encoding UTF8
  }

  ## ���[�N�u�b�N�����(false:�ۑ����Ȃ�)
  $workbook.Close($false)
}

function Import-NameDefinitions {
  param(
    [string]$TextFilePath,
    [string]$ExcelFilePath
  )
  ## ���[�N�u�b�N���J��
  $workbook = $excel.Workbooks.Open($ExcelFilePath)

  ## ���O��`�t�@�C����ǂ݁A���[�N�u�b�N�ɒǉ�
  ## ���ɓ������O��`�����݂��Ă�����㏑��
  $nameDefinitions = Get-Content -Path $TextFilePath
  foreach ($definition in $nameDefinitions) {
    ## ���O�ƒ�`���e�̓^�u��؂�
    $parts = $definition -split "`t"
    $name = $parts[0]
    $refersTo = $parts[1]
    try{
      $workbook.Names.Add($name, $refersTo)
    } catch{
      ## ���[�U����`���Ă��Ȃ����O��`(_xlfn��_xlpm)��Add���悤�Ƃ����
      ## ��O����������̂ŃL���b�`���邪�A���̖��O��`�̒ǉ��ɐi�悤�ɂ��Ă���B
      Write-Host $name "�̖��O��`�̒ǉ��ŃG���[���������܂���: $_"
      Write-Host "���̖��O��`�̒ǉ����p�����܂��B"
    }
  }
  ## ���[�N�u�b�N�����(true:�㏑���ۑ�)
  $workbook.Close($true)
}

## Excel�A�v���P�[�V�����I�u�W�F�N�g���쐬
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

try {
  ## ���̓p�X�Əo�̓p�X���΃p�X�ɕϊ�
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
  Write-Host "�G���[���������܂���: $_"
} finally {
  ## �I�u�W�F�N�g�����
  $excel.Quit()
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
  Remove-Variable excel
}

Write-Host "���삪�������܂����B"
