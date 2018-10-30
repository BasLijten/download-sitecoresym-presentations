Function Download-Presentations
{
    #Set security protocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $loginUrl = "https://sitecoresymposium2018.smarteventscloud.com/connect/processLogin.do"
    #$loginUrl = "https://sitecoresymposium2018.smarteventscloud.com/connect/loginDialog.ww"
    $response = Invoke-WebRequest -Uri $loginUrl -SessionVariable 'sessionVars'    

    $credentials = @{
        #'pageUrl'='https://sitecoresymposium2018.smarteventscloud.com/connect/publicDashboard.ww';
        'username'= 'BobbyHack';
        'password'='SitecoreSymposium2018WasAwesome!';
    }

    #$sendCredentialsUrl  = "https://sitecoresymposium2018.smarteventscloud.com/connect/loginDialog.ww"
    $sendCredentialsUrl = "https://sitecoresymposium2018.smarteventscloud.com/connect/processLogin.do"
    $headers = @{

    }
    $loginResponse = Invoke-WebRequest -Uri $sendCredentialsUrl -Method Post -Body $credentials -WebSession $sessionVars    

    #searching
    $searchUri = "https://sitecoresymposium2018.smarteventscloud.com/connect/search.ww"
    $searchResult = Invoke-WebRequest -Uri $searchUri -WebSession $sessionVars
    
    $sessions = Get-Content ".\sessionIDs.txt"
    foreach($session in $sessions)
    {

        $pptUri = "https://sitecoresymposium2018.smarteventscloud.com/connect/dwr/call/plaincall/ConnectAjax.getSessionFiles.dwr"
        $postParams = @{
        callCount=1;
        windowName='';
        'c0-scriptName'='ConnectAjax';
        'c0-methodName'='getSessionFiles';
        'c0-id'='0';
        'c0-param0'='string:'+ $session;
        'batchId'='5';
        'instanceId'='0';
        'page'='%2Fconnect%2Fsearch.ww';
        'scriptSessionId'='wdG*tmfxl6sh0jRbZ9fm6JAbNqm/kvWb5rm-T23kkIf93'
        }   

        $reply = Invoke-WebRequest -Uri $pptUri -Method POST -Body $postParams -WebSession $sessionVars    

        $tempVar = ConvertFrom-String $reply.Content
        $json = '{\"data\":' + $tempVar.P11 + 'kb\"}]}'  
    
        $unescaped = [System.Text.RegularExpressions.Regex]::Unescape($json)
        $parsedObject = ConvertFrom-Json $unescaped

        Invoke-WebRequest -Uri $parsedObject.data[0].url -OutFile "D:\symp\$($session).pdf"

        #Start-BitsTransfer -Source $parsedObject.data[0].url -Destination "D:\symp\"
    }

    
}


Login