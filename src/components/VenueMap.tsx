import { useEffect, useState } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

type Pin = {
  index: number;
  name: string;
  category: "restaurant" | "cocktail bar";
  lat: number;
  lng: number;
};

function numberedIcon(index: number, isBar: boolean) {
  const bg = isBar ? "#7c3aed" : "#ea580c";
  const html = `<div style="background:${bg};color:#fff;width:30px;height:30px;border-radius:50% 50% 50% 0;transform:rotate(-45deg);display:flex;align-items:center;justify-content:center;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.35);font-weight:700;font-family:ui-sans-serif,system-ui;font-size:13px"><span style="transform:rotate(45deg)">${index}</span></div>`;
  return L.divIcon({
    html,
    className: "",
    iconSize: [30, 30],
    iconAnchor: [15, 28],
    popupAnchor: [0, -26],
  });
}

export function VenueMap({
  center,
  pins,
}: {
  center: [number, number];
  pins: Pin[];
}) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  if (!mounted) {
    return <div className="h-72 w-full animate-pulse rounded-xl border border-border bg-muted/40 md:h-96" />;
  }

  const lats = pins.map((p) => p.lat);
  const lngs = pins.map((p) => p.lng);
  const bounds: L.LatLngBoundsExpression | undefined =
    pins.length > 0
      ? [
          [Math.min(...lats), Math.min(...lngs)],
          [Math.max(...lats), Math.max(...lngs)],
        ]
      : undefined;

  return (
    <div className="h-72 w-full overflow-hidden rounded-xl border border-border md:h-96">
      <MapContainer
        center={center}
        zoom={13}
        bounds={bounds}
        boundsOptions={{ padding: [30, 30] }}
        scrollWheelZoom={false}
        style={{ height: "100%", width: "100%" }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        {pins.map((p) => (
          <Marker
            key={`${p.index}-${p.name}`}
            position={[p.lat, p.lng]}
            icon={numberedIcon(p.index, p.category === "cocktail bar")}
          >
            <Popup>
              <strong>
                {p.index}. {p.name}
              </strong>
              <br />
              <span style={{ textTransform: "capitalize" }}>{p.category}</span>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}
