/*
 * Copyright 2019 ThoughtWorks, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {MithrilViewComponent} from "jsx/mithril-component";
import * as m from "mithril";
import * as css from "./user_input_pane.scss";

interface Attrs {
  heading: string;
}

export class UserInputPane extends MithrilViewComponent<Attrs> {
  view(vnode: m.Vnode<Attrs>) {
    return <section class={css.userInput}>
      <h3 class={css.sectionHeading}>{vnode.attrs.heading}</h3>
      <p class={css.sectionNote}><span class={css.attention}>*</span> denotes a required field</p>
      {vnode.children}
    </section>;
  }
}
