function getCurrentLocation()
{
    console.log("LatitudeDataManager: getCurrentLocation() called");
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4 && req.status == 200) {
            var result = eval('(' + req.responseText + ')');
            if(result["kind"] === "error") {
                console.log("Error occured", result)
            } else {
                pageLocation.currentLocation = result["data"]
            }
        } else if(req.readyState == 4) {
            pageLocation.currentLocation = req.status;
            console.log("getCurrentLocation(), status = " + req.status + "\n");
            console.log("getCurrentLocation(), response headers:\n", req.getAllResponseHeaders());
            console.log("getCurrentLocation(), responseText", req.responseText);
        }
        pageLocation.runBusyIndicator(false);
    }
    pageLocation.runBusyIndicator(true);
    req.open("GET", "https://www.googleapis.com/latitude/v1/currentLocation?granularity=best&access_token=" + google_oauth.accessToken, true); //asynchronouse
    req.send(null);
}

function insertCurrentLocation(lat, lng)
{
    console.log("LatitudeDataManager: insertCurrentLocation() called. Latitude="+lat+", longitude="+lng);
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4 && req.status == 200) {
            console.log("responseText", req.responseText);
            var result = eval('(' + req.responseText + ')');
            if(result["kind"] === "error") {
                console.log("Error occured", result)
            } else {
                pageLocation.currentLocation = result["data"]
            }
        } else if(req.readyState == 4) {
            pageLocation.currentLocation = req.status;
            console.log("insertCurrentLocation(), req.status="+req.status);
            console.log("insertCurrentLocation(), response headers:\n", req.getAllResponseHeaders());
            console.log("insertCurrentLocation(), responseText", req.responseText);
        }
        pageLocation.runBusyIndicator(false);
    }
    pageLocation.runBusyIndicator(true);
    req.open("POST", "https://www.googleapis.com/latitude/v1/currentLocation?access_token=" + google_oauth.accessToken, true); //asynchronouse
    req.setRequestHeader("Content-Type","application/json");
    var postData = '{"data": {"kind": "latitude#location", "latitude": '+lat+', "longitude": '+lng+'}}';
    req.send(postData);
}

function getHistoryLocation()
{
    console.log("LatitudeDataManager: getHistoryLocation() called");
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4 && req.status == 200) {
            var result = eval('(' + req.responseText + ')');
            if(result["kind"] === "error") {
                console.log("Error occured", result)
            } else {
                pageLocation.locationHistory = result["data"]["items"]
            }
        } else if(req.readyState == 4) {
            pageLocation.locationHistory = req.status;
            console.log("getHistoryLocation(), req.status="+req.status);
            console.log("getHistoryLocation(), response headers:\n", req.getAllResponseHeaders());
            console.log("getHistoryLocation(), responseText", req.responseText);
        }
        pageLocation.runBusyIndicator(false);
    }
    pageLocation.runBusyIndicator(true);
    req.open("GET", "https://www.googleapis.com/latitude/v1/location?granularity=best&max_results=10&access_token=" + google_oauth.accessToken, true); //asynchronouse
    req.send(null);
}

function insertHistoryLocation(lat, lng, ms)
{
    console.log("insertHistoryLocation(). lat="+lat+", lng="+lng+", ms="+ms);
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4 && req.status == 200) {
            console.log("insertHistoryLocation(), responseText", req.responseText);
            var result = eval('(' + req.responseText + ')');
            if(result["kind"] === "error") {
                console.log("Error occured", result)
            } else {
                pageLocation.locationInserted = true;
            }
        } else if(req.readyState == 4) {
            pageLocation.locationInserted = req.status;
            console.log("insertHistoryLocation(), req.status="+req.status);
            console.log("insertHistoryLocation(), response headers:\n", req.getAllResponseHeaders());
            console.log("insertHistoryLocation(), responseText", req.responseText);
        }
        pageLocation.runBusyIndicator(false);
    }
    pageLocation.runBusyIndicator(true);
    req.open("POST", "https://www.googleapis.com/latitude/v1/location?access_token=" + google_oauth.accessToken, true); //asynchronouse
    req.setRequestHeader("Content-Type","application/json");
    var postData = '{"data": {"kind": "latitude#location", "latitude": '+lat+', "longitude": '+lng+', "timestampMs": "'+ms+'"}}';
    req.send(postData);
}

function gotoAddress(address, key)
{
    var client = new XMLHttpRequest();
    client.onreadystatechange = function() {
        // in case of network errors this might not give reliable results
        if(client.readyState === XMLHttpRequest.DONE)
        {
            var result = eval('(' + client.responseText + ')');

            var placeMarks = result["Placemark"];
            if(placeMarks.length === 0)
            {
                console.log("No placeMarks")
                return;
            }

            console.log("placeMarks.length", placeMarks.length)

            var lng  = placeMarks[0]["Point"]["coordinates"][0];
            var lat = placeMarks[0]["Point"]["coordinates"][1];
            console.log("lat, lng", lat, lng);

            gotoLocation(lat,lng);

            busy_indicator.running = false;
            busy_indicator.visible = false;
        }
    }
    client.open("GET", "http://maps.google.com/maps/geo?q=" + address+ "&key="+key+"&output=json&oe=utf8&sensor=false",true);
    busy_indicator.running = true;
    busy_indicator.visible = true;
    client.send();
}
