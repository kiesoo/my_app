$(document).ready(function(){
    $('#favourite').click(function(){
        $.post($(this).attr('src'), function(data){
            if (data.success == 'true'){
                $('#info').html($('#favourite').attr('class')+' was successfully added to favorite list').slideDown('slow').delay(3000).fadeOut();
            }
        });
    });
    
    $('.ranking').mouseover(function(){
        var rank = $(this).attr('name');
        
        for (var i = 1; i <= rank; i++){
            $('#ranking' + i).attr('src', '/images/icons/ranking_full.png');
        }
        
        for (var i = (parseInt(rank)+1); i <= 5; i++){
            $('#ranking' + i).attr('src', '/images/icons/ranking.png');
        }
    });
    $('.ranking').mouseout(function(){
        var rank = $('#ranking').attr('class');
        
        for (var i = 1; i <= rank; i++){
            $('#ranking' + i).attr('src', '/images/icons/ranking_full.png');
        }
        
        for (var i = (parseInt(rank)+1); i <= 5; i++){
            $('#ranking' + i).attr('src', '/images/icons/ranking.png');
        }
    });
    
    //AJAX Requests to ShoppingCarts controller
    $('#add_to_cart').click(function(){
        $.post($(this).attr('src'), function(data){
            if (data.success == 'true'){
                $('#info').html('Movie was successfully added to cart').slideDown('slow').delay(3000).fadeOut();
            }else{
                $('#info').html('Invalid movie').slideDown('slow').delay(3000).fadeOut();    
            }
        });
    });
    
    $('.pieces').keyup(function(){
        if ($(this).val()){
            $.post("shoppingcarts/update/"+$(this).attr('name')+"/"+$(this).val(), function(data){
                if (data.success == 'true'){
                    $('#info').html('Quantity was successfully changed').slideDown('slow').delay(3000).fadeOut();
                }else{
                    $('#info').html('Invalid movie').slideDown('slow').delay(3000).fadeOut();    
                }
            });
        }
    });
    //END AJAX Requests to ShoppingCarts controller
});