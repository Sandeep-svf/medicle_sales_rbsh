# Beat Management flow review

The existing TerritoryMapScreen, TerritoryController, TerritoryRepository,
BeatCard, BeatLegend, TerritoryQuickActions, CreateBeatBottomSheet,
AreaCircleWidget, and AreaDetailController were read without modifying them.

## API contract used by the new screen

| Action | Request | Body / response |
| --- | --- | --- |
| Load / refresh | GET territory/master | areas, doctors, chemists, stockists, beats, beatAreas |
| Create | POST beats | name, areaIds, color |
| Edit | PUT beats/{beatId} | name, areaIds, color |
| Delete | DELETE beats/{beatId} | No body |

Authentication and the company backend URL use the existing THttpHelper.
Writes reuse TerritoryRepository; no API requests were executed as part of this review.
Successful writes reload territory/master. Failed writes preserve the draft.

## Selection and relationships

- Nationwide browsing uses lib/utils/json_data/Datagov_Pincode_Boundaries.geojson.
- India mode renders viewport boundaries from zoom 7 and labels from zoom 11;
  nationwide search remains available at every zoom. Search results are limited
  to 100 listed pincodes; the UI asks users to narrow larger result sets.
- Postal circles are searchable metadata, not administrative state boundaries.
- Bihar district mode matches postal divisions (including known name aliases)
  and displays the full pincode polygons; neighboring divisions are excluded.
- Map polygons are display geometry; GeoJSON pincodes are not server area IDs.
- Match a pincode to all registered areas whose pincode matches it.
- Selecting another pincode adds its IDs to a Set; it does not replace earlier selections.
- Selecting a fully selected pincode again removes only that pincode's IDs.
- Individual registered areas can be selected or removed separately.
- Partial selection is shown using a mixed-state checkbox.
- Bulk selection applies only to the currently listed pincodes and preserves other selections.
- Changing districts preserves the draft. Clear/discard explicitly removes it.
- Edit preloads the beat's name, color, and linked areas.
- Beat memberships come from beatAreas (beat_id / area_id).
- Assigned doctor counts follow the existing controller: master doctors filtered by areaId.
- Offline doctors remain visible on the map; geometric counts are labeled as mapped doctors.
- Area details include assigned beats, doctors, chemists, and stockists.

## Additional active controls

The new screen includes view/edit/delete, beat dates, beat colors, layer controls,
head-office navigation using login data, and multi-district beat previews.
It owns its state and does not register or mutate the existing GetX controllers.

## Existing placeholders

The original offline download/check/delete methods are empty and their screen
controls are commented out. There is no implemented offline basemap API to port.
The original remark field is not part of create/update API bodies.
The original distance estimate is selected-area count multiplied by 2.8; it is
not a calculated route. The new screen does not present that number as mileage.

## Creation order

The screen starts with Bihar territory selection. Nationwide pincodes remain
available through the always-visible map switch. Select multiple pincode areas
first, then tap Create beat. A separate form collects the name and color and
sends the accumulated registered area IDs only when Save beat is pressed.
Back to selection closes the form without discarding the draft.

## Compact map selection and beat colors

- Tap pincodes to add them; tap selected pincodes to deselect them.
- Map taps keep the inspector closed. A compact, horizontally scrollable tray
  shows all selected post offices and pincodes, with remove and clear controls.
- Continue opens a dedicated creation page. Name/color drafts and selected IDs
  survive returning to the map and failed saves.
- The page offers exactly 15 swatches from TColors.mapBeatPalette. An existing
  custom beat color is retained unless the user explicitly changes it.
- Assigned pincode polygons use beat colors. Shared post offices can be included
  in multiple beats; colored outlines and label markers show their memberships.
- Unassigned pincodes retain the API area-ID green/red registration colors.
- Existing Beat Management screens, controller, repository and API payloads
  were not changed by this update.
