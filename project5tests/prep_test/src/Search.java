import java.io.*;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.sql.DataSource;
import javax.swing.plaf.synth.SynthSeparatorUI;

import java.sql.*;
import HelperClasses.*;
import java.util.*;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
/**
 * Servlet implementation class weInBoys
 */
@WebServlet("/Search")
public class Search extends HttpServlet {
//	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		long SstartTime= System.nanoTime();
		response.setContentType("text/html");
		System.out.println("Trying to connect...");
		HttpSession mySession = request.getSession();
		try{
//			Connection connection = Database.openConnection();
			Context initCtx = new InitialContext();
			Context envCtx = (Context) initCtx.lookup("java:comp/env");
			DataSource ds = (DataSource) envCtx.lookup("jdbc/moviedb");
			
			Connection connection = ds.getConnection(); 
			
			 
			int page = 1;
			if (request.getParameter("page")!= null){
				page = Integer.parseInt(request.getParameter("page"));
			}
			
			String title = request.getParameter("title");

			String title1 = request.getParameter("textsearch");
			
			if (title == null && title1 != null) {
				title = title1;
			}
			String year;
			String director;
			String firstname;
			String lastname;
			System.out.println(title);
			if (title == title1) {
				 year = "";
				 director = ""; 
				 firstname = "";
				 lastname = "";
			}
			else {
			 year = request.getParameter("yearinput");
			 director = request.getParameter("director"); 
			 firstname = request.getParameter("firstname");
			 lastname = request.getParameter("lastname");
			
			}
			String[] queryInputs = {title, year, director, firstname, lastname};

			
			for (String s : queryInputs){
				System.out.println(s);
			}
			
			long JstartTime  = System.nanoTime();
			List<Movie> movieList = getMovieList(queryInputs, connection);
			long JendTime = System.nanoTime();
			long JelapsedTime = JendTime - JstartTime;
			
			
			
			request.setAttribute("page", page);
			request.setAttribute("movieList", movieList);
			request.setAttribute("movieListSize", movieList.size());
			long SendTime = System.nanoTime();
			long SelapsedTime = SendTime-SstartTime;
			write(request,SelapsedTime, JelapsedTime);
			request.getRequestDispatcher("movielist.jsp").forward(request, response);
			
		} catch (Exception e){
			e.printStackTrace();
		}
		
	}
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	
	public List<Movie> getMovieList(String[] queryInputs, Connection connection) {
		List<Movie> movieList = new ArrayList<Movie>();
		
		try {
			Statement statement = connection.createStatement();
			String query = "SELECT DISTINCT movies.id, movies.title, movies.year, movies.director, movies.banner_url, movies.trailer_url "
					+ "FROM (movies CROSS JOIN stars) CROSS JOIN stars_in_movies WHERE "
					+"(stars_in_movies.star_id = stars.id AND stars_in_movies.movie_id =movies.id)" ;
			
			
			query = createStringQuery(query, queryInputs);//for total results
			ResultSet result = statement.executeQuery(query);
			movieList = BrowseByTitle.returnMovieList(result, connection);
			MovieList storedMovieList = new MovieList(movieList, query);
					
			result.close();
			statement.close();
			connection.close();
			return movieList;
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return movieList;
		
	}
	
	public static List<Movie> returnMovieList(ResultSet result, Connection connection) {
		List<Movie> movieList = new ArrayList<Movie>();
		
		try {
			while(result.next()) {
				Movie m = new Movie();
				m.id = result.getInt("id");
				m.year = result.getInt("year");
				m.title = result.getString("title");
				m.director = result.getString("director");
				m.banner_url = result.getString("banner_url");
				m.trailer_url = result.getString("trailer_url");
				
				String query = "SELECT DISTINCT * FROM stars s LEFT OUTER JOIN stars_in_movies sm ON sm.star_id=s.id where sm.movie_id = ?";
				PreparedStatement getStars = connection.prepareStatement(query);
				getStars.setInt(1, m.id);
				ResultSet starsResult = getStars.executeQuery();
				
				while(starsResult.next()) {
					Star s = new Star();
					s.id = starsResult.getInt("id");
					s.fn = starsResult.getString("first_name");
					s.ln = starsResult.getString("last_name");
					s.dob = starsResult.getString("dob");
					s.photo_url = starsResult.getString("photo_url");
					m.starsInMovie.add(s);
				}
				starsResult.close();
				getStars.close();
				
				String query2 = "SELECT DISTINCT * FROM genres g LEFT OUTER JOIN genres_in_movies gm ON gm.genre_id=g.id where gm.movie_id = ?";

				PreparedStatement getGenres = connection.prepareStatement(query2);
				getGenres.setInt(1,m.id);
				ResultSet genresResult = getGenres.executeQuery();
				
				while(genresResult.next()) {
					String g = genresResult.getString("name");
					m.genresInMovie.add(g);
				}
				genresResult.close();
				getGenres.close();
				
				movieList.add(m);
				
			}
			return movieList;
		} catch(Exception e) {
			e.printStackTrace();
		}
		return movieList;
	}
	
	//using the QueryField enum, adds to the query string according to what type of value the item is
	private String addFieldToWhere(String query, QueryField fieldToAdd, String fieldValue ) {
		String finalQuery = query;
			if (fieldValue != ""){
				finalQuery = finalQuery + " AND " + fieldToAdd.name 
					+ " " + fieldToAdd.fieldValuePrefix + fieldValue + fieldToAdd.fieldValueSuffix;
			}
			
		return finalQuery;
	}
	
	
	private String createStringQuery(String query, String[] queryInputs){
		String result = query;
		
		Map<QueryField, String> queryItems = new HashMap<QueryField,String>();
		queryItems = populateHashMap(queryItems, queryInputs);
		for (QueryField Key : queryItems.keySet() ){
			result = addFieldToWhere(result, Key, queryItems.get(Key));
		}
				
		return result;
	}
	
	//populates the hashmap that will be used to create the rest of the query after WHERE
	private Map<QueryField, String> populateHashMap(Map<QueryField, String> queryItems, String[] queryInputs){ 
		Map<QueryField, String> resultMap = queryItems;
		for (int i = 0; i< queryInputs.length;i++){
			if (i ==0){
				resultMap.put(QueryField.Title, queryInputs[0]);
			}
			else if (i==1){
				resultMap.put(QueryField.Year, queryInputs[1]);
			}
			else if (i==2){
				resultMap.put(QueryField.Director, queryInputs[2]);
			}
			else if (i==3){
				resultMap.put(QueryField.FirstName, queryInputs[3]);
			}
			else if (i==4){
				resultMap.put(QueryField.LastName, queryInputs[4]);
			}
		}
		return resultMap;
	}
	
	
	public void write(HttpServletRequest request,long ServletTime, long JDBCtime){
		try{
			String filename = request.getServletContext().getRealPath("/jmeterTest.txt");
			FileWriter writer = new FileWriter(filename,true);
			writer.write("Servlet Time elapsed:\t" + ServletTime + "\t JDBC Time elapsed:\t" + JDBCtime + "\n");
			writer.flush();
			writer.close();
		} catch (Exception e){
			e.printStackTrace();
		}
	}

}