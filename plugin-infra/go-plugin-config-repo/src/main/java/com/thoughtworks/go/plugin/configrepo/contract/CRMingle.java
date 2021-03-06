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
package com.thoughtworks.go.plugin.configrepo.contract;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EqualsAndHashCode(callSuper = true)
public class CRMingle extends CRBase {
    @SerializedName("base_url")
    @Expose
    private String baseUrl;
    @SerializedName("project_identifier")
    @Expose
    private String projectIdentifier;
    @SerializedName("mql_grouping_conditions")
    @Expose
    private String mqlGroupingConditions;

    public CRMingle() {
    }

    public CRMingle(String baseUrl, String projectId) {
        this.baseUrl = baseUrl;
        this.projectIdentifier = projectId;
    }
    
    @Override
    public void getErrors(ErrorCollection errors, String parentLocation) {
        String location = getLocation(parentLocation);
        errors.checkMissing(location, "project_identifier", projectIdentifier);
        errors.checkMissing(location, "base_url", baseUrl);
    }

    @Override
    public String getLocation(String parent) {
        String myLocation = getLocation() == null ? parent : getLocation();
        return String.format("%s; Mingle", myLocation);
    }
}
