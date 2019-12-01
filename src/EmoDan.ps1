<# このスクリプトはマルウェアなどに感染したことは判明した場合にLANケーブル抜線や無線LAN無効化などが
　　速やかにできない環境向けに作ったものです。主に中小零細企業においてクソ高いEDRなんぞ導入できないで
　　あろうところを想定しています。

　　本スクリプト実行後、有効化されているネットワークインターフェースを無効化（遮断）します。
　　また、ついでにネットワーク接続状況やプロセス稼働状況などの情報の取得します。

　　・出力されるファイル
　　　- netconnection.txt ネットワーク接続状況です。
　　　- process.txt プロセス稼働状況です。
　　　- netadapter-status.txt 有効化されていた（遮断対象となった）ネットワークインターフェースです。

　　Windows 10環境で動作確認しておりますが、動作保証はしませんのでご利用の際は事前にご自身の環境で
　　動作確認を行なって下さい。　

　　【実行時の注意】本スクリプトは管理者権限でご利用下さい！
#>

# 開始メッセージ
Write-Host "これより緊急ネットワーク遮断を行います。"

# ネットワーク接続状況の取得
Get-NetTCPConnection| Select LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess, @{n="ProcessName";e={(Get-Process -Id $_.OwningProcess).ProcessName}} , @{n="UserName";e={(Get-Process -Id $_.OwningProcess -IncludeUserName).UserName}}| Where {$_.State -eq"Established"} |FT -autosize -Force >netconnection.txt

# プロセス稼働状況の取得
Get-Process -IncludeUserName|Select Id, ProcessName, UserName |FT -autosize -Force >process.txt

# 有効化されているネットワークインターフェースの情報取得と無効化
Get-NetAdapter|? status -eq up >netadapter-status.txt
Get-NetAdapter|? status -eq up|Disable-NetAdapter -Confirm:$false

# 終了メッセージ
Write-Host "処理が終了しました。"