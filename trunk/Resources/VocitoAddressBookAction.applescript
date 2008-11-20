--
--  Call using VocitoAddressBookAction.applescript
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

using terms from application "Address Book"
	on action property
		return "phone"
	end action property
	
	on action title for aPerson with aNumber
		return ("Vocito: Call " & (value of aNumber as string))
	end action title
	
	on should enable action for aPerson with aNumber
		return true
	end should enable action
	
	on perform action for aPerson with aNumber
		set aNumber to (value of aNumber as string)
		using terms from application "Vocito"
			tell application "Vocito"
				dial aNumber
			end tell
		end using terms from
		return true
	end perform action
end using terms from