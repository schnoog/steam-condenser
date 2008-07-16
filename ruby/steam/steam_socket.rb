class SteamSocket < CondenserSocket

  def get_reply
    reply_packet = self.read_packet
    
    debug "Got reply of type \"#{reply_packet.class.to_s}\"."
    
    return reply_packet    
  end

  def read_packet
    self.read_to_buffer 1400
    
    if self.get_long == -2
      begin
        request_id = self.get_long
        packet_count = self.get_byte
        packet_number = self.get_byte + 1
        split_size = self.get_short
        if packet_number == 1
          self.get_long
        end
        split_packets[packet_number] = self.flush_buffer
        
        if packet_number < packet_count
          self.read_to_buffer 1400
        end
        
        debug("Received packet #{packet_number} of #{packet_count} for request ##{request_id}")
      end while packet_number < packet_count && self.get_long == -2
      return SteamPacket.create_packet(split_packets.join(""))
    else
      return SteamPacket.create_packet(self.flush_buffer)
    end
  end
  
end