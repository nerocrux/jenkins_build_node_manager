$(document).ready(function() {
    $.fn.editable.defaults.mode = 'popup';     
    $('.node').editable({
        params: function(params) {
            var data = {};
            data['_csrf_token'] = $(this).data("csrf");
            data['job'] = params.name;
            data['node'] = params.value;
            return data;
        },
    });
    
    $('.tags').editable({
        params: function(params) {
            var data = {};
            data['_csrf_token'] = $(this).data("csrf");
            data['job'] = params.name;
            data['tags'] = params.value;
            return data;
        },
    });
    
    products = [];
    $('.product').data("products").split(',').forEach(e => products.push({value: e, text: e}))
    $('.product').editable({
        source: products,
        params: function(params) {
            var data = {};
            data['_csrf_token'] = $(this).data("csrf");
            data['job'] = $(this).attr('id');
            data['product'] = params.value;
            return data;
        },
        success: function(response, newValue) {
            // TODO update tr class name
        }
    });
    
    $('#batchEditNodeModalSubmitBtn').click(function() {
        $('#batchEditNodeModalSubmitForm').submit();
    });
});

function switchProduct(product) {
    $('.nav-item').removeClass("active");
    $('#'+product+'-tab').addClass("active");
    products = $('.product').data("products").split(',');
    products.push("all");
    products.forEach(e => {$('.tr-'+e).hide();});
    $('.tr-'+product).show();
}
