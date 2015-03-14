$(function(){

    $("ul.menu li").hover(function(){
    
        $(this).addClass("hover");
        $('ul:first',this).css('display', 'block');
    
    }, function(){
    
        $(this).removeClass("hover");
        $('ul:first',this).css('display', 'none');
    
    });
    
    $("ul.menu li ul li:has(ul)").find("a:first").append(" &raquo; ");

});