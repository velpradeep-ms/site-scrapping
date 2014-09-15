
  $("#submit_url").click(function(e)

  {
      if ($("#search_url").val() == "")
      {
          alert("Please enter the url")
          e.preventDefault();
      }


  });
