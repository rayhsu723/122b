<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "HelperClasses.*, java.util.*, java.math.*"  %>
 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Search Results</title>
<style>
        	body {background-color : #ADD8E6}
        	body {font-family:Arial}
        	h2 {text-align : right}
        	.tooltip {
			    position: relative;
			    display: inline-block;
			    border-bottom: 1px dotted black;
			}
			
			.tooltip .tooltiptext {
			    visibility: hidden;
			    width: 400px;
			    height: 400px;
			    background-color: black;
			    color: #fff;
			    text-align: center;
			    border-radius: 6px;
			    padding: 5px 0;
			
			    /* Position the tooltip */
			    position: absolute;
			    z-index: 1;
			}
			
			.tooltip:hover .tooltiptext {
			    visibility: visible;
			}
</style>


</head>
<body>
	<h2><a href="shoppingCart.jsp">Shopping Cart</a></h2>
 	<table style="width:100%" border="1">
		<h1>Found ${movieListSize} result(s). </h1>
		<tr>
			<td>Movie ID</td>
			<td>
				Title
				<a href= "Pages?fn=<%="title"%>&sort=<%="asc"%>">Asc</a>
				<a href= "Pages?fn=<%="title"%>&sort=<%="desc"%>">Desc</a>
			</td>
			<td>
				Year
				<a href= "Pages?fn=<%="year"%>&sort=<%="asc"%>">Asc</a>
				<a href= "Pages?fn=<%="year"%>&sort=<%="desc"%>">Desc</a>				
			</td>
			<td>Director</td>
			<td>Genres</td>
			<td>Stars</td>
			
		</tr>
		<%

		int currentPage = (Integer)request.getAttribute("page");
		int moviesPerPage = 50;
		
		List<Movie> movieList = (List)request.getAttribute("movieList");
		
		int numOfPages = (int) Math.ceil((movieList.size()*1.0)/moviesPerPage);
		

 		request.setAttribute("movieList", movieList);
		
		int size = movieList.size();

		
		for(int i = (currentPage-1)*moviesPerPage; i < (currentPage-1)*moviesPerPage+moviesPerPage; ++i) {
			if (i<size){
		%>
		<tr>
			<td><%= movieList.get(i).id %></td>
			<td><a href="movieinfo.jsp?title=<%=movieList.get(i).title%>&id=<%=movieList.get(i).id%>" class="tooltip"><%= movieList.get(i).title %>
				<span class="tooltiptext">
					<%= movieList.get(i).title%> [<%=movieList.get(i).year%>]<br>
					<img src= <%=movieList.get(i).banner_url %> width="150" height="250"><br>
					Stars:
					<% int starsize = movieList.get(i).starsInMovie.size();
						for (int j = 0; j <starsize-1; ++j) { %>
							<%=movieList.get(i).starsInMovie.get(j).fn %> <%=movieList.get(i).starsInMovie.get(j).ln %>, 
						<%}%>
						<%=movieList.get(i).starsInMovie.get(starsize-1).fn %> <%=movieList.get(i).starsInMovie.get(starsize-1).ln%>
					
					<form name="addMovietoCart" action="CartPages?request=add_item&quantity=1&id=<%=movieList.get(i).id %>" method="POST">
						<button type="submit" >Add Movie to Cart</button>
					</form>
				</span>
			</a>
			</td>
			<td><%= movieList.get(i).year %></td>
			<td><%= movieList.get(i).director %></td>
			<td> <b>GENRES</b>
			<%List<String> genre_list = new ArrayList<String>();
			  int genre_size = movieList.get(i).genresInMovie.size();
				for(int j = 0; j < genre_size; ++j) { 
					genre_list.add(movieList.get(i).genresInMovie.get(j));%>
<%-- 					<p> <%= movieList.get(i).genresInMovie.get(j) %></p>
 --%>					<%}%>
				<%for(String g : genre_list) {%>
				<p><a href="BrowseByGenre?genre=<%=g%>"><%=g%></a></p>
				<%}%>
			</td>
			
			<td> <b>STARS</b>
			<% int star_size = movieList.get(i).starsInMovie.size(); 
				for(int j = 0; j < star_size; ++j) {
				int id = movieList.get(i).starsInMovie.get(j).id;
				String first_name = movieList.get(i).starsInMovie.get(j).fn;
				String last_name = movieList.get(i).starsInMovie.get(j).ln;
				String dob = movieList.get(i).starsInMovie.get(j).dob;
				String photo_url = movieList.get(i).starsInMovie.get(j).photo_url;
				List<String> movie_list = movieList.get(i).starsInMovie.get(j).featuredMoviesTitle;
				request.getSession().setAttribute("movie_list",movie_list);
				
				%>
				<p> <a href="starinfo.jsp?fn=<%=first_name%>&ln=<%=last_name%>&id=<%=id%>&photo_url=<%=photo_url%>&dob=<%=dob%>"><%= first_name %> <%= last_name %> </a></p>
				<%}%>
			</td>
			
			<td>
				<form name="addMovietoCart" action="CartPages?request=add_item&quantity=1&id=<%=movieList.get(i).id %>" method="POST">
					<button type="submit" >Add Movie to Cart</button>
				</form>
			</td>
		</tr>
			<%}%>
		<%}%>
	</table>
	<br>
	<%

		if (currentPage != 1){%>
		 	<a href= "Pages?page=<%=currentPage-1%>"> Previous </a>
	 <%}%>
	
	<table border = "1">
	 	<%
	 	for (int i = 1; i<=numOfPages;i++){
	 		if (i ==currentPage){%>
	 			<td> <%=i%> </td>
	 		<%}
	 		else{%>
	 			<td> <a href= "Pages?page=<%=i%>"><%= i%> </a></td>
	 		<%}%>
	 		
	 	<%} %>
	 	</tr>
	 </table> <br>
	 
	<%if (currentPage < numOfPages){%>
		<a href = "Pages?page=<%=currentPage+1%>">Next</a>
	<%} %>
	

</body>
</html>