# NAS Mount Configuration

## Current Setup
- **NAS IP:** 192.168.1.205
- **Share:** Public
- **Mount Point:** /mnt/nas
- **Type:** CIFS (SMB)

## Credentials File (~/.creds)
Create this file in your home directory:
```ini
username=nik
password=YOUR_PASSWORD
```
Set permissions: `chmod 600 ~/.creds`

## fstab Entry
Add to `/etc/fstab`:
```
//192.168.1.205/Public /mnt/nas cifs credentials=/home/nik/.creds,iocharset=utf8,uid=1000,gid=1000 0 0
```

## Manual Mount (Testing)
```bash
sudo mount -t cifs //192.168.1.205/Public /mnt/nas -o credentials=~/.creds,uid=1000,gid=1000
```

## Troubleshooting
- Check NAS is reachable: `ping 192.168.1.205`
- Test mount without fstab first
- Ensure `_netdev` is NOT used for CIFS (only NFS)
- Set credentials file permissions: `chmod 600 ~/.creds`
