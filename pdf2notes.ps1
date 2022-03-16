# temberature@gmail.com
# English

param (
    [string]$pdfpattern = "Z:\EnglishBooks\*.pdf",
    [string]$mdLoc = "C:\Users\16052\Downloads\booknotes0315\"
)
 
Function Get-StringHash { 
    param
    (
        [String] $String,
        $HashName = "MD5"
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
    $algorithm = [System.Security.Cryptography.HashAlgorithm]::Create('MD5')
    $StringBuilder = New-Object System.Text.StringBuilder 
  
    $algorithm.ComputeHash($bytes) | 
    ForEach-Object { 
        $null = $StringBuilder.Append($_.ToString("x2")) 
    } 
  
    $StringBuilder.ToString() 
}
Function Get-StringHash6 {
    param
    (
        [String] $String
    )
    (Get-StringHash $String ).substring(0, 6)
}
Write-Host "loading加载中"
# $WshShell = New-Object -comObject WScript.Shell


Get-ChildItem -Path $pdfpattern -Recurse | Where-Object { $_.FullName -notlike '*_ori*' } | ForEach-Object {
    $_.FullName
    $bookfile = $_.FullName.Substring(0, $_.FullName.LastIndexOf('.'))
    $pdf = $bookfile + ".pdf"
    $json = $bookfile + ".json"

    if (!(Get-Item $json) -or (Get-Item $json).LastWriteTime -lt $_.LastWriteTime) {
        pdfannots $pdf -f json -o $json
    }
    
    $psobject = Get-Content -LiteralPath $json | ConvertFrom-Json 
    if ($psobject.length -lt 1) {
        return
    }
    $offset = stapler list-logical $pdf | Select-Object -last 1  | ForEach-Object { (-split $_)[1] - (-split $_)[0] }
    # Write-Host $offset
    $name = [io.path]::GetFileNameWithoutExtension($_.FullName)
    New-Item -Path $mdLoc -Name $name -ItemType "directory" -Force
    $dir = $mdLoc + $name + "\"
    $md = $mdLoc + $name + ".md"
    # # $md = $bookfile + '.' + $psobject.length + ".md"
    # if (Get-Item $md) {
    #     $links = Get-Content $md | Select-String -Pattern '.*\[\[.+\]\].*' | ForEach-Object {$_.Matches.Groups[0].Value}
    # }
    # $currentChapter = ''
    # $raw = '';
    Clear-Variable -Name "prior_outline"
    Clear-Variable -Name "block"
    Clear-Variable -Name "text"
    Clear-Variable -Name "mdName"
    Clear-Variable -Name "blockMD"
    Clear-Variable -Name "links"
    if (-not $plainBlock -eq $null) {
        Clear-Variable -Name "plainBlock"
    }
    if (-not $target -eq $null) {
        Clear-Variable -Name "target"
    }
    Clear-Variable -Name "currentChapter"
    $content = $psobject | ForEach-Object { 
        Clear-Variable -Name "prior_outline"
        Clear-Variable -Name "block"
        Clear-Variable -Name "text"
        Clear-Variable -Name "mdName"
        Clear-Variable -Name "blockMD"
        Clear-Variable -Name "links"
        if (-not $plainBlock -eq $null) {
            Clear-Variable -Name "plainBlock"
        }
        if (-not $target -eq $null) {
            Clear-Variable -Name "target"
        }
        # Write-Host $prior_outline
        if ($_.prior_outline -ne '') {
            $prior_outline = $_.prior_outline.replace("`n", ", ").replace("`r", ", ")
            if (($prior_outline -ne $currentChapter) -or ($currentChapter -eq '')) {
                # $mdName = $name + '_' + (Get-StringHash6 $prior_outline ) + '.md'
                # $blockMD = $dir + $mdName
                # if (Get-Item $blockMD) {
                #     $links = Get-Content $blockMD | Select-String -Pattern '.*\[\[.+\]\].*' | ForEach-Object {$_.Matches.Groups[0].Value}
                # }
                # "#"*$prior_outline.split(' ')[0].split('.').length
                $block = "{1} {0}" -f $prior_outline, ("#" * $prior_outline.split(' ')[0].split('.').length) | Out-String 
                # # $raw = $raw + $block +'\n';
                # $links | ForEach-Object {
                #     $main = $_.substring(0, $_.length - 8)
                #     $block = $block.replace($main.replace('[[', '').replace(']]', ''), $main);
                # }
                # Write-Host $block, $blockMD
                "`n" + $block
            }
        }
        $text = $_.text -replace '([^a-zA-Z]) +([^a-zA-Z])', '$1$2'
        $text = $text -replace '([a-zA-Z]) +([a-zA-Z])', '$1 $2'
        $mdName = $name + '_' + (Get-StringHash6 $text ) + '.md'
        $blockMD = $dir + $mdName        
        if (Get-Item $blockMD) {
            $links = Get-Content $blockMD | Select-String -Pattern '.*\[\[.+\]\].*' | ForEach-Object { $_.Matches.Groups[0].Value }
        }
        # '* {2}: [#{0}](hook://{1}#{3})' -f ($_.page - $offset), $pdf.replace('\', '/').replace(' ', '%20'), $text, $_.page | Out-String | Out-File -LiteralPath ($dir + $mdName)
        $block = "---`ncssclass: note`n---`n`n* {2}: [#{0}](hook://{1}#{3})" -f ($_.page - $offset), $pdf.replace('\', '/').replace(' ', '%20'), $text, $_.page | Out-String
        # $raw = $raw + $block +'\n';
        $links | ForEach-Object {
            $main = $_
            $plainBlock = $block -replace '(.*?)\[\[([^\|]*?)\]\](.*?)', '$1$2$3' -replace '(.*?)\[\[(?:.*?)\|(.*?)\]\](.*?)', '$1$2$3'
            $target = $main -replace '(.*?)\[\[([^\|]*?)\]\](.*?)', '$1$2$3' -replace '(.*?)\[\[(?:.*?)\|(.*?)\]\](.*?)', '$1$2$3'
            if ($plainBlock.contains($target)) {
                $block = $block.replace($target, $main);                
            }
            else {
                $block += ("`n" + $main)
            }
        }
        Write-Host $block, $blockMD
        $block | Out-File -LiteralPath ($blockMD)
        '![[{0}]]' -f $mdName
        $currentChapter = $prior_outline
    } | Out-String
    # $links | ForEach-Object {
    #     $content = $content.replace($_.replace('[[', '').replace(']]', ''), $_);
    # }
    "---`ncssclass: overview`n---`n`n{0}" -f $content | Out-File -LiteralPath $md
    $script = $PSScriptRoot + "\keywords.py"
    python $script $md
    
    # [io.path]::GetFileNameWithoutExtension("Z:\1读秀\4.0\a_14597902_OCR9.md")
    # $name = Split-Path -Path $md -Leaf -Resolve
    # $Shortcut = $WshShell.CreateShortcut("Z:\pdfnotes\" + $name + ".lnk")
    # $Shortcut.TargetPath = $md
    # $Shortcut.Save()

    
} 
cmd /c pause