(function(window) {

	/*
	* PhoneGap is available under *either* the terms of the modified BSD license *or* the
	* MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
	*
	* Copyright (c) 2005-2010, Nitobi Software Inc., Brett Rudd, Jesse MacFadyen
	*/

	var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

	var WebRTC = function() { 
        this.successCallback = null;
        this.errorCallback = null;
        this.videoElement = null;
	}

	WebRTC.prototype = {
 
        getUserMedia: function(options, successCallback, errorCallback)
        {
            if (successCallback)
            {
                window.plugins.webRTC.successCallback = successCallback.name;
            }
 
            if (errorCallback)
            {
                window.plugins.webRTC.errorCallback = errorCallback.name;
            }
 
            var video = document.getElementById('video');
            var position = findAbsolutePosition(video);
            var height = video.height;
            var width = video.width;

            var callbacks = {
                successCallback: 'window.plugins.webRTC.onSuccessCallback',
                errorCallback: 'window.plugins.webRTC.onErrorCallback',
            };
            cordovaRef.exec('WebRTC.getUserMedia', callbacks);
        },

        onSuccessCallback: function(pindex) {
            if (this.successCallback)
            {
                var fn = window[this.successCallback];
                if(typeof fn === 'function')
                {
                    fn(pindex);
                } 
            }
        },

        onErrorCallback: function(pindex) {
            if (this.errorCallback)
            {
                var fn = window[this.errorCallback];
                if(typeof fn === 'function')
                {
                    fn(pindex);
                } 
            }
        }
 
	};

	cordovaRef.addConstructor(function() {
		window.plugins = window.plugins || {};
		window.plugins.webRTC = new WebRTC();
	});

}(window));