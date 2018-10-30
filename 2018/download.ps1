Function Download-Presentations
{
    #Set security protocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $loginUrl = "https://sitecoresymposium2018.smarteventscloud.com/connect/processLogin.do"

    #initial request for login page - get all cookies as well
    #set session variable to share all cookeis and other session variables
    $response = Invoke-WebRequest -Uri $loginUrl -SessionVariable 'sessionVars'

    $credentials = @{
        'username'= 'BobbyHack';
        'password'='SitecoreSymposium2018WasAwesome!';
    }

    #send credentials
    $sendCredentialsUrl = "https://sitecoresymposium2018.smarteventscloud.com/connect/processLogin.do"

    #response will have the auth cookies
    $loginResponse = Invoke-WebRequest -Uri $sendCredentialsUrl -Method Post -Body $credentials -WebSession $sessionVars

    #open search page
    $searchUri = "https://sitecoresymposium2018.smarteventscloud.com/connect/search.ww"
    $searchResult = Invoke-WebRequest -Uri $searchUri -WebSession $sessionVars

    #already got all session ID's - don't have to parse the HTML :D
    $sessions = Get-Content ".\sessionIDs.txt"

    #foreach session, get the download link (behind authroization)
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

        #parse the returned message. This is hard, as it is javascript with some json inside it. The javascript needs to be stripped and the json needs to be parsed
        $tempVar = ConvertFrom-String $reply.Content
        $json = '{\"data\":' + $tempVar.P11 + 'kb\"}]}'

        #unescape the json
        $unescaped = [System.Text.RegularExpressions.Regex]::Unescape($json)
        $parsedObject = ConvertFrom-Json $unescaped

        #get the download url and download the session
        Invoke-WebRequest -Uri $parsedObject.data[0].url -OutFile "D:\symp\$($session).pdf"

        #Start-BitsTransfer -Source $parsedObject.data[0].url -Destination "D:\symp\"
    }
}

Download-Presentations
