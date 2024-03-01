// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
declare function require(name: string): string

// tslint:disable-next-line
require("../css/app.css")

import "phoenix_html"

import ReactPhoenix from "./ReactPhoenix"
import DisruptionCalendar from "./components/DisruptionCalendar"
import DisruptionForm from "./components/DisruptionForm"

declare global {
  interface Window {
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

window.Components = { DisruptionCalendar, DisruptionForm }

ReactPhoenix.init()

window.addEventListener("message", async (e) => {
  if (e.origin !== location.origin) {
    return;
  }
  if (typeof e.data !== "string") {
    return
  };
  console.log(e);
  if (e.data.slice(0, location.origin.length) !== location.origin) {
    return;
  }

  const query = e.data.slice(e.data.indexOf("?"));
  console.log(query);

  try {
    await fetch("/auth/keycloak_prompt_none/callback" + query)
  } catch (e) {
    console.log(e);
  }
}, false);
