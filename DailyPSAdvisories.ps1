# Daily PacketStorm advisory emails filtered by keywords
$Keywords = @("Red Hat", "McAfee", "Google", "Mozilla", "Microsoft")

$Today = Get-Date -Format "yyyy-MM-dd"
$Feed = "https://rss.packetstormsecurity.com/files/dates/$Today/"
$Entries = @()

$Request = Invoke-WebRequest -UseBasicParsing -ContentType "application/xml" $Feed
If ( $Request.StatusCode -ne "200" ) {
    Write-Host "Message: $($Request.StatusCode) $($Request.StatusDescription)"
}
$FeedXml = [xml]$Request.Content

ForEach ($Item in $FeedXml.rss.channel.item) {
    If ( $Keywords | ? { $Item.description -match $_ } ) {
        $Entries += [PSCustomObject]@{
            'Title' = $Item.title
            # 'Link' = $Item.link
            "Comments" = $Item.comments
            # "PubDate" = $Item.pubDate
            "Description" = $Item.description
            # "Category" = $Item.category
        }
    }
}

$FeedData = $Entries | Format-List
$FeedTitle = $($FeedXml.rss.channel.title -replace "Files Date: ") + " Advisories"

$Params = @{
    'Body' = $FeedData
    'BodyAsHtml' = $true
    'From' = "advisories@example.com"
    'SmtpServer' = "smtp.example.com"
    'Subject' = $Feedtitle
    'To' = "alerts@example.com"
}

Send-MailMessage @Params
