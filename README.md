# EarthquakeViewer

Welcome to the Earthquake Viewer repository.

## Dependencies

No third party libraray is needed

## Functionalities
* Can retrieve earthquakes info from https://earthquake.usgs.gov/fdsnws/event/1/
* Based on user location, app can retrieve earthquakes that happen within 50 kilometers in recent 30 days(by default)
* User can also select to type in (lat, lon) manually, to see earthquakes near a certain location
* CoreLocation is used, in order to retreieve users' location

## Architecture
* MVVM pattern is used in this project, `ViewController`, `ViewModel` and `EarthquakeManager` are responsible for certain aspects
** `ViewController` is the main VC in this app, it holds a `StackView` which has a list of earthquakes info
** `ViewModel` is the main VM, which is responsible for the functionalities that doesn't to be in VC
** `EarthquakeManager` is responsible for building Request, fire request and construct data model as well. Some location managements happen here also

## UI
* Main VC is a scorllview which has a StackView within it
*                        -inputLocationView, which has two textfields, and two buttons("use above locations" button and "use current location" buton)
* VC-ScorllView-StackView-EarthquakeView, which has earthquake info, like title, magnitude and details link
*                        -EarthquakeView ...


