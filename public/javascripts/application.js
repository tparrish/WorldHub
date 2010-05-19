// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
    $('#upload').validate();
    $("input.submit").attr("disabled", "disabled");
    var token = $("input[name=upload_token]").val();
    $("#zip_input").uploadify({
        'uploader': '/flash/uploadify.swf',
        'script': $('#upload_path').val(),
        'fileDataName': "world[zip]",
        'scriptData': {
            'upload_token': token
        },
        //'scriptAccess': 'always', // Incomment this, if for some reason it doesn't work
        'auto': true,
        'fileDesc': 'Zip files only',
        'fileExt': '*.zip',
        'width': 120,
        'height': 24,
        'cancelImg': '/images/cancel.png',
        'onComplete': function(event, data) {
            $("input.submit").removeAttr("disabled");
        },
        // We assume that we can refresh the list by doing a js get on the current page
        'displayData': 'speed'
    });

	$('#embedder').ajaxForm({
	    dataType: 'text',
	    success: function(data) {
			$('#errors').remove()
	        $('#embed_code').text(data);
	    },
	    error: function(data) {
		
			if($('#errors').length !== 0) {
				$('#errors').replaceWith($(data.responseText));
			}
			else {
				$('#embedder').before(data.responseText)
			}
	    }
	});

	if ($('#embedder input.fullscreen:checked').val() !== undefined) {
		
	    $('#embedder input.dimension').attr("disabled", "disabled");
	}

	$('#embedder input.fullscreen').change(function() {
	    if ($('#embedder input.fullscreen:checked').val() !== undefined) {
	        $('#embedder input.dimension').attr("disabled", "disabled");
	    }
	    else {
	        $('#embedder input.dimension').removeAttr("disabled");
	    }
	});
});