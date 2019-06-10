// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:tweets", {})

// multi-column support
let messageContainers = document.querySelectorAll("[id*='message_column']")
let n_columns = messageContainers.length;

var column = 0; // where we put the tweets
channel.on("new_tweet", sentweet => {
  console.log("sentweet", sentweet)

  var tweet_message = document.getElementById("tweet-message");
  var new_tweet = tweet_message.cloneNode(true);
  new_tweet.style = null;

  new_tweet.querySelector("#header").style.backgroundColor = sentweet.score_style.color;
  new_tweet.querySelector("#score").innerText = sentweet.score;
  new_tweet.querySelector("#sentiment").innerText = sentweet.sentiment;
  new_tweet.querySelector("#emoji").innerHTML = sentweet.score_style.emoji;

  new_tweet.querySelector("#profile-image").src = sentweet.user.profile_image_url;
  new_tweet.querySelector("#user-name").innerText = sentweet.user.name;
  new_tweet.querySelector("#screen-name").innerText = sentweet.user.screen_name;

  var current_time = Date.now();
  var tweet_time = new Date(sentweet.created_at);
  var minutes = ((current_time - tweet_time) / 60000).toFixed(2);
  new_tweet.querySelector("#tweet-time").innerText = minutes;

  new_tweet.querySelector("#user-tweets").innerText = sentweet.user.statuses_count;
  new_tweet.querySelector("#user-followers").innerText = sentweet.user.followers_count;

  new_tweet.querySelector("#tweet-text").innerText = sentweet.text;

  new_tweet.querySelector("#reply-count").innerText = sentweet.reply_count;
  new_tweet.querySelector("#retweet-count").innerText = sentweet.retweet_count;
  new_tweet.querySelector("#like-count").innerText = sentweet.favorite_count;

  messageContainers[column].prepend(new_tweet);
  column = (column + 1) % n_columns; // next column
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
