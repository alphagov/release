$(function () {
    $("#task_version").autocomplete({
        source:function (req, resp) {
            var applicationId = $("#task_application_id").val();
            if (applicationId) {
                $.ajax({
                    url:"/applications/" + applicationId + "/tags?term=" + req.term,
                    dataType:"json",
                    success:resp
                });
            }
        }
    });
});