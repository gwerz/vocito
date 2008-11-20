--
--  main.applescript
--
--  Copyright 2008 Google Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License"); you may not
--  use this file except in compliance with the License.  You may obtain a copy
--  of the License at
-- 
--  http:--www.apache.org/licenses/LICENSE-2.0
-- 
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
--  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
--  License for the specific language governing permissions and limitations under
--  the License.
--

on run {input, parameters}
	set toNumber to ""
	set fromNumber to ""
	try
		set toNumber to (|toNumber| of parameters)
	end try
	try
		set fromNumber to (|fromNumber| of parameters)
	end try
	if input is not {} then
		if class of input is list then
			set theNumber to item 1 of input
		else
			set theNumber to input
		end if
		if (|inputOptions| of parameters) is equal to 0 then
			set toNumber to theNumber
		else if (|inputOptions| of parameters) is equal to 1 then
			set fromNumber to theNumber
		end if
	end if
	tell application "Vocito"
		if length of fromNumber > 0 then
			dial toNumber from fromNumber
		else
			dial toNumber
		end if
	end tell
	
	return input
end run
