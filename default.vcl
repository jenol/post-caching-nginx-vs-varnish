vcl 4.1;
import std;
import bodyaccess;

backend default {
    .host = "node";
    .port = "3000";
}

backend prometheus {
    .host = "prometheus";
    .port = "9090";
}

sub vcl_recv {

	if (req.url == "/ready") {
        return (synth(750));
    }
	
	if (req.url == "/metrics") {
        set req.backend_hint = prometheus;
    } else {
		set req.backend_hint = default;
		unset req.http.X-Body-Len;
		unset req.http.x-cache;
		std.log("Will cache POST for: " + req.http.host + req.url);
		if (req.method == "POST") {
			std.log("Will cache POST for: " + req.http.host + req.url);
			std.cache_req_body(500KB);
			set req.http.X-Body-Len = bodyaccess.len_req_body();
			if (req.http.X-Body-Len == "-1") {
				return(synth(400, "The request body size exceeds the limit"));
			}
			return (hash);
		}
	}
}

sub vcl_synth {
    if (resp.status == 750) {
        set resp.status = 200;
        synthetic("Ok");
        return(deliver);
    }
}

sub vcl_hash {
    # To cache POST and PUT requests
    if (req.http.X-Body-Len) {
        bodyaccess.hash_req_body();
    } else {
        hash_data("");
    }
}

sub vcl_backend_fetch {
    if (bereq.http.X-Body-Len) {
        set bereq.method = "POST";
    }
}

sub vcl_hit {
	set req.http.x-cache = "hit";
}

sub vcl_miss {
	set req.http.x-cache = "miss";
}


sub vcl_deliver {
	set resp.http.X-Cached = req.http.x-cache;
}
