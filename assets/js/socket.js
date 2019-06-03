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
let messageContainers = document.querySelectorAll("[id*='messages']")

// add positional formatting function to String types
String.prototype.positional_format = function () {
  var i = 0, args = arguments;

  // replace instances of {} with array elements
  return this.replace(/{}/g, function () {
    return typeof args[i] != 'undefined' ? args[i++] : '';
  });
};

// template string containing {} braces to be filled by
// the positional formatting function
// field order:
//    1 div color
//    2 sentiment
//    3 score
//    4 emoji
//    5 tweet
let template = `
<div class="tile is-ancestor">
  <div class="tile is-parent">
    <a class="tile is-child notification"
       style="background-color:{}">
      <p class="title has-text-dark"> {} score: {} {} </p>
      <p class="subtitle has-text-dark"> {} </p>
    </a>
  </div>
</div>
`;

// return hex color given sentiment score
// linear gradient between Bulma is-danger and is-success
function score_color(score) {
  if (score < -0.75) {
    return "#ff3860"; // very negative is-danger
  } else if (score < -0.25) {
    return "#da768a"; // mostly negative
  } else if (score < 0.25) {
    return "#b5b5b5"; // neutral is-gray-light
  } else if (score < 0.75) {
    return "#6cc38a"; // mostly positive
  } else {
    return "#23d160"; //very positive is-success
  }
}

// return emoji given sentiment score
function score_emoji(score) {
  if (score < -0.75) {
    return "\u{1F92C}"; // very negative f-bomb
  } else if (score < -0.25) {
    return "\u{1F928}"; // mostly negative skeptical
  } else if (score < 0.25) {
    return "\u{1F610}"; // neutral flat mouth
  } else if (score < 0.75) {
    return "\u{1F642}"; // mostly positive smirk
  } else {
    return "\u{1F911}"; //very positive money eyes
  }
}

var column = false;
channel.on("new_tweet", payload => {

  console.log("payload", payload)

  let tileContainer = document.createElement('div');
  tileContainer.innerHTML = template.positional_format(
      score_color(payload.score),
      payload.sentiment,
      payload.score.toFixed(2),
      score_emoji(payload.score),
      payload.text
  );

  // unary + converts bool to int
  messageContainers[+column].prepend(tileContainer)
  column = !column; // alternate

})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
