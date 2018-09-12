clear-host
# creating user variables
$proxy = ""
$timeoutsec = 10
$filepath = $PSSCriptroot + '\data.json'

$outputDate = Get-Date -format "yyyy-MM-dd hhmmss tt"
$sw = [system.diagnostics.stopwatch]::startNew()
$arr = @()

#reading content of the file and converting from JSON
$jsonobject = Get-Content $filepath | Out-String | ConvertFrom-Json 

#Creating table to collect URLs from tile
$urlchecklist = New-Object system.Data.DataTable
$identifier =  New-Object system.Data.DataColumn identifier,([string])
$filefield =  New-Object system.Data.DataColumn filefield,([string])
$url =  New-Object system.Data.DataColumn url,([string])
$urlchecklist.columns.add($identifier)
$urlchecklist.columns.add($filefield)
$urlchecklist.columns.add($url)

#Looping through each object in JSON file
Foreach ($object in $jsonobject) {

#read each field to see if url exist
if($object.context -like '*http*') {

$row = $urlchecklist.NewRow()

    $row.identifier = "JSON level"
    $row.filefield = "JSON.context"
    $row.url = $object.context
   
$urlchecklist.Rows.Add($row)
}


if($object.conformsTo -like '*http*') {

$row = $urlchecklist.NewRow()

    $row.identifier = "JSON level"
    $row.filefield = "JSON.conformsTo"
    $row.url = $object.conformsTo

$urlchecklist.Rows.Add($row)
}

if($object.describedBy -like '*http*') {
$row = $urlchecklist.NewRow()

    $row.identifier = "JSON level"
    $row.filefield = "JSON.describedBy"
    $row.url = $object.describedBy

$urlchecklist.Rows.Add($row)
}


#looping through each dataset in JSON file to collect URL and store in table
foreach($dataset in $object.dataset){

        if($dataset.conformsTo -like '*http*') {

            $row = $urlchecklist.NewRow()

                $row.identifier = $dataset.identifier
                $row.filefield = "dataset.conformsTo"
                $row.url = $dataset.conformsTo

            $urlchecklist.Rows.Add($row)

        }


        if($dataset.describedBy -like '*http*') {

            $row = $urlchecklist.NewRow()

                $row.identifier = $dataset.identifier
                $row.filefield = "dataset.describedBy"
                $row.url = $dataset.describedBy

            $urlchecklist.Rows.Add($row)

        }

        if($dataset.landingpage -like '*http*') {

            $row = $urlchecklist.NewRow()

                $row.identifier = $dataset.identifier
                $row.filefield = "dataset.landingpage"
                $row.url = $dataset.landingpage

            $urlchecklist.Rows.Add($row)

        }

        if($dataset.license -like '*http*') {

            $row = $urlchecklist.NewRow()

                $row.identifier = $dataset.identifier
                $row.filefield = "dataset.license"
                $row.url = $dataset.license

            $urlchecklist.Rows.Add($row)

        }

# looping for each url in references    
      $dataset.references | ForEach-Object -Process { 
  
                if($_ -like '*http*') {

                $row = $urlchecklist.NewRow()

                    $row.identifier = $dataset.identifier
                    $row.filefield = "dataset.references"
                    $row.url = $_

                $urlchecklist.Rows.Add($row)

                }
              }


                        #looping through each distribution in dataset
                        foreach($distribution in $dataset.distribution) {


                            if($distribution.downloadURL -like '*http*') {

                                $row = $urlchecklist.NewRow()

                                    $row.identifier = $dataset.identifier
                                    $row.filefield = "dateset.distribution.downloadURL"
                                    $row.url = $distribution.downloadURL

                                $urlchecklist.Rows.Add($row)

                            }

                            if($distribution.accessURL -like '*http*') {

                                $row = $urlchecklist.NewRow()

                                    $row.identifier = $dataset.identifier
                                    $row.filefield = "dateset.distribution.accessURL"
                                    $row.url = $distribution.accessURL

                                $urlchecklist.Rows.Add($row)

                            }

                            if($distribution.conformsTo -like '*http*') {

                                $row = $urlchecklist.NewRow()

                                    $row.identifier = $dataset.identifier
                                    $row.filefield = "dateset.distribution.conformsTo"
                                    $row.url = $distribution.conformsTo

                                $urlchecklist.Rows.Add($row)

                            }

                            if($distribution.describedBy -like '*http*') {

                                $row = $urlchecklist.NewRow()

                                    $row.identifier = $dataset.identifier
                                    $row.filefield = "dateset.distribution.describedBy"
                                    $row.url = $distribution.describedBy

                                $urlchecklist.Rows.Add($row)

                            }
    }
  }
}

#start testing urls from table
write-output "Test of URL Begin"

#looping through each row in the table to test each url    
foreach ($url in $urlchecklist) {

#checking array if url is already tested     
    if ($arr.url -eq $url.url) {
        
      $filter = $arr.where({$_.url -eq $url.url}, 1) 

            write-output "Already tested url"

            $arr += [pscustomobject]@{
            DataSetID=$url.identifier;
            FileField=$url.filefield;
            url=$url.url;
            WebFormat=$filter.webFormat;
            StatusCode=$filter.StatusCode;
            WebsiteModifiedDate=$filter.WebsiteModifiedDate;

            }
        $filter = ''
        } 
        #testing url and logging results into an array
        else 
        {

    write-output "Testing Begin" , $url.identifier,  $url.url
            try {
                if ($proxy -like '*http*')
                {
                $info=Invoke-WebRequest -Uri $url.url -Method Head -Proxy $proxy  -ProxyUseDefaultCredentials -TimeoutSec $timeoutsec
                }
                else
                {
                $info=Invoke-WebRequest -Uri $url.url -Method Head -TimeoutSec $timeoutsec
                }
            } catch {
                $request = $_.Exception.Response
            }

                        if($info.Length -gt 0) {
                           $result = [int] $info.statusCode
                           $websiteDt = $info.BaseResponse.LastModified
       
                           $raw = $info.RawContent.Split("`r`n");
       
                           foreach($i in $raw) {
                                if( $i.Length -ne 0 -and $i.Length -ge 11) {
                                    if($i.Substring(0,12) -eq 'Content-Type') {
                                        $webFormat = $i.Substring(14) 
                                    }
                                }
                            } 

       

                        } 
                        else {
                           $result = [int] $request.StatusCode
                           $websiteDt = ''
                        }

    
        $arr += [pscustomobject]@{
                DataSetID=$url.identifier;
                FileField=$url.filefield;
                url=$url.url;
                WebFormat=$webFormat;
                StatusCode=$result;
                WebsiteModifiedDate=$websiteDt.Date;
        }
        $info = ''
        $request = ''
        $result=''

        write-output "Testing Complete " 
    }
} 

write-output "Test of URL End"

#creating .csv file output for test results
$fileOutput = $PSSCriptroot + ".\DataFileLinksResults " + $outputDate  + "-from datajson.csv"
$arr | export-csv $fileOutput -NoTypeInformation
$sw.Stop() 
$host.ui.RawUI.ForegroundColor = "magenta" 
write-output "TOTAL TIME FOR JOB: " $sw.Elapsed.toString() 
$host.ui.RawUI.ForegroundColor = "white" 

#removing varaibles
Remove-Variable * -ErrorAction SilentlyContinue