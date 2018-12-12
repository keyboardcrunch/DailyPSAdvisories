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

$style = @"
    <style>
    @charset "UTF-8";

    table
    {
    font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse:collapse;
    }
    td
    {
    font-size:1em;
    border:1px solid #98bf21;
    padding:5px 5px 5px 5px;
    }
    th
    {
    font-size:1.1em;
    text-align:center;
    padding-top:5px;
    padding-bottom:5px;
    padding-right:7px;
    padding-left:7px;
    background-color:#A7C942;
    color:#ffffff;
    }
    name tr
    {
    color:#F00000;
    background-color:#EAF2D3;
    }
    </style>
"@

[string]$FeedData = $Entries | Select-Object Title, Description, Comments | ConvertTo-HTML -Head $style
$FeedTitle = $($FeedXml.rss.channel.title -replace "Files Date: ") + " Advisories"

$Params = @{
    'Body' = $FeedData
    'BodyAsHtml' = $true
    'From' = "test@example.com"
    'SmtpServer' = "smtp.example.com"
    'Subject' = $Feedtitle
    'To' = "test@example.com"
}

Send-MailMessage @Params
