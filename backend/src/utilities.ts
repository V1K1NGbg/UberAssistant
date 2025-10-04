import { CustomerRequest, DriverStatus } from "./storage";
import fs from 'fs';


// Haversine distance in kilometers
function haversineDistance(
  lat1: number, lon1: number, lat2: number, lon2: number
): number {
  const R = 6371.0; // Earth's radius in km

  // Convert degrees to radians
  const toRad = (deg: number) => deg * Math.PI / 180;
  lat1 = toRad(lat1);
  lon1 = toRad(lon1);
  lat2 = toRad(lat2);
  lon2 = toRad(lon2);

  // Differences
  const dlat = lat2 - lat1;
  const dlon = lon2 - lon1;

  // Haversine formula
  const a = Math.sin(dlat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

// Distance measure between two points
function distanceMeasure(point1: [number, number], point2: [number, number]): number {
  return haversineDistance(point1[0], point1[1], point2[0], point2[1]);
}


type DensityPoint = [number, number];

// Compute score
function getScore(driver: DriverStatus, request: CustomerRequest, densityPoint: DensityPoint): number {
  const rawData = fs.readFileSync('../../model/model.json', 'utf-8');
  const data = JSON.parse(rawData);
  const [x, y, z, w] = data;

  return x * request.price
       + y * request.duration_mins
       + z * distanceMeasure([driver.location.lat, driver.location.lon], [request.from_location.lat, request.from_location.lon])
       + w * distanceMeasure([request.to_location.lat, request.to_location.lon], densityPoint)
       - x ** 2 - y ** 2 - z ** 2 - w ** 2;
}

export function getAdvice(driver: DriverStatus, request: CustomerRequest): string {
  const densityDataRaw = fs.readFileSync('../../storage/density_data.json', 'utf-8');
  const densityData = JSON.parse(densityDataRaw);
  const densityPoints: DensityPoint = densityData.density_points;
  const score = getScore(driver, request, densityPoints);

  if (score > 10) {
    return "Yes";
  } else {
    return "No";
  }
}

export function getRequests(): CustomerRequest[] {
  const rawData = fs.readFileSync('../storage/requests.json', 'utf-8');

  const data = JSON.parse(rawData);
  const formattedRequests: CustomerRequest[] = data.map((req: any) => ({
    customer_id: req.customer_id,
    from_location: {
      lat: req.pickup_lat,
      lon: req.pickup_lon
    },
    to_location: {
      lat: req.drop_lat,
      lon: req.drop_lon
    },
    duration_mins: req.duration_mins,
    price: req.net_earnings
  }));

  return formattedRequests;
}
